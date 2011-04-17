#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import <objc/message.h>
#import "NSObject+AliasMethodChain.h"

#import "ItemsAppDelegate.h"
#import "ListsViewController.h"
#import "NSUserDefaults+.h"
#import "ASIHTTPRequest.h"
#import "Synchronizer.h"
#import "ItemList.h"
#import "NSErrorCategories.h"
#import "NSManagedObjectContextCategories.h"

@interface TextListsTests : SenTestCase {
@private
    ItemsAppDelegate *m_appDelegate;
    ListsViewController *m_listsViewController;
}
@end

@implementation TextListsTests
+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // use in memory store coordinator for CoreData records
    [ItemsAppDelegate aliasInstanceMethod:@selector(persistentStoreCoordinator) chainingPrefix:@"memory" withBlock:^(id _self) {
        Ivar ivar = class_getInstanceVariable([_self class], "m_persistentStoreCoordinator");
        id coordinator = object_getIvar(_self, ivar);
        
        if (coordinator != nil) {
            return coordinator;
        }
        NSError *error = nil;
        coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[_self managedObjectModel]];
        if (![coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
            [error prettyPrint];
            abort();
        }
        object_setIvar(_self, ivar, coordinator);
        return coordinator;
    }];
    [pool release];
}

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    //NSLog(@"setup");
    [AliasMethodChainTracer startTracingAliasesAll];
    [NSUserDefaults resetToAppDefaults];
    m_appDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(m_appDelegate, @"Cannot find the application delegate");
    m_listsViewController = (ListsViewController *)m_appDelegate.navigationController.topViewController;
}

- (void)tearDown
{
    // Tear-down code here.
    //NSLog(@"tearDown");
    [AliasMethodChainTracer revertTracedAliasesAll];
    [super tearDown];
}

- (void)testOpenAuthPage
{
    id appMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    [[appMock expect] openURL:[NSURL URLWithString:@"http://textlists.yakitara.com:8080/api/key?r=items://sync/"]];
    
    objc_msgSend(m_listsViewController, @selector(sync));
    
    [appMock verify];
}

- (void)testSettingApiKey
{
    // Ensure no additional process save for setting ApiKey and UserId
    //   Empty postQueue will not be processed
    [Synchronizer aliasClassMethod:@selector(singletonSynchronizer) chainingPrefix:@"mock" withBlock:^(id _class) {
        id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_singletonSynchronizer))];
        [[[mock stub] andReturn:[NSArray array]] postQueue];
        return mock;
    }];
    // Skip actual GET /api/changes
    [Synchronizer aliasInstanceMethod:@selector(getChangeLog) chainingPrefix:@"mock" withBlock:^(id _self) {
        [_self stop];
    }];
    
    // Simulate redirection from AuthPage of the web site
    NSString *apiKey = @"ABCDEFG";
    NSString *userId = @"12345";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"items://sync/?key=%@&user_id=%@", apiKey, userId]];
    STAssertNoThrow([m_appDelegate application:[UIApplication sharedApplication] handleOpenURL:url], @"");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    STAssertEqualObjects(apiKey, [defaults objectForKey:@"ApiKey"], @"");
    STAssertEqualObjects(userId, [defaults objectForKey:@"UserId"], @"");
}

- (void)testPostInBox
{
    // Set dummy ApiKey to avoid to get the key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"ABCDEFG" forKey:@"ApiKey"];
    [defaults setObject:@"12345" forKey:@"UserId"];
    // Post /api/changes will response id:10001
    [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock" withBlock:^(id _class, NSURL *url) {
        id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_requestWithURL:), url)];
        [[[mock stub] andDo:^(NSInvocation *invocation) {
            [[[mock stub] andReturnValue:[NSNumber numberWithInt:200]] responseStatusCode];
            [[[mock stub] andReturn:@"{\"id\": 10001}"] responseString];
            [[mock delegate] performSelector:[mock didFinishSelector] withObject:mock];
        }] startAsynchronous];
        return mock;
    }];
    // Skip actual GET /api/changes
    [Synchronizer aliasInstanceMethod:@selector(getChangeLog) chainingPrefix:@"mock" withBlock:^(id _self) {
        [_self stop];
    }];
    
    STAssertNoThrow(objc_msgSend(m_listsViewController, @selector(sync)), @"");
    
    NSManagedObjectContext *context = m_appDelegate.managedObjectContext;
    id list = [context fetchFirstFromEntityName:@"List" withPredicateFormat:@"name == 'in-box'" argumentArray:[NSArray array]];
    STAssertEquals(10001, [[list valueForKey:@"id"] intValue], @"");
}

// - (void)testGetNoContent
// {
//     //   GET /api/chageLog will be "204 No Content"
//     [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock" withBlock:^(id _class, NSURL *url) {
//         id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_requestWithURL:), url)];
//         [[[mock stub] andDo:^(NSInvocation *invocation) {
//             id requestMock = [invocation target];
//             [[[requestMock stub] andReturnValue:[NSNumber numberWithInt:204]] responseStatusCode];
//             [requestMock requestFinished];
//         }] startAsynchronous];
//         return mock;
//     }];
// }
@end
