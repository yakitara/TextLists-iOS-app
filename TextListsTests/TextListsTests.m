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
#import "Item.h"
#import "Listing.h"
#import "NSErrorCategories.h"
#import "NSManagedObjectContextCategories.h"
#import "JSON.h"

@interface ItemsAppDelegate (Test)
- (void)resetPersistentStoreCoordinator;
@end

@implementation ItemsAppDelegate (Test)
- (NSPersistentStoreCoordinator *)memory_persistentStoreCoordinator {
    if (m_persistentStoreCoordinator != nil) {
        return m_persistentStoreCoordinator;
    }
    NSError *error = nil;
    m_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objc_msgSend(self, @selector(managedObjectModel))];
    if (![m_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
        [error prettyPrint];
        abort();
    }
    return m_persistentStoreCoordinator;
}

- (void)resetPersistentStoreCoordinator {
    [m_persistentStoreCoordinator release];
    m_persistentStoreCoordinator = nil;
    [m_managedObjectContext release];
    m_managedObjectContext = nil;
    [m_listsFetchedResultsController release];
    m_listsFetchedResultsController = nil;
}
@end


@interface TextListsTests : SenTestCase {
@private
    ItemsAppDelegate *m_appDelegate;
    ListsViewController *m_listsViewController;
    BOOL m_postBulkChanges;
}
- (void)setupApiKey;
- (void)mockEmptyPostQueue;
- (void)mockGetChangeLogDoesNothing;
//- (void)mockNoCntentGetRequest;
@end

@implementation TextListsTests
+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // use in memory store coordinator for CoreData records
    [ItemsAppDelegate aliasInstanceMethod:@selector(persistentStoreCoordinator) chainingPrefix:@"memory"];
    [pool release];
}

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    //NSLog(@"setup");
    [AliasMethodChainTracer startTracingAliasesAll];
    m_appDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(m_appDelegate, @"Cannot find the application delegate");
    m_listsViewController = (ListsViewController *)m_appDelegate.navigationController.topViewController;
    (void)m_listsViewController.inbox;  // re-create in-box if not exists
}

- (void)tearDown
{
    // Tear-down code here.
    //NSLog(@"tearDown");
#if 1
    [m_appDelegate resetPersistentStoreCoordinator];
    m_listsViewController.inbox = nil;
#else
    NSPersistentStoreCoordinator *coordinator = m_appDelegate.managedObjectContext.persistentStoreCoordinator;
    NSError *error = nil;
    if (![coordinator removePersistentStore:[[coordinator persistentStores] lastObject] error:&error]) {
        [error prettyPrint];
        STFail(@"");
    }
    
    if (![coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
        [error prettyPrint];
        STFail(@"");
    }
#endif
    [NSUserDefaults resetToAppDefaults];
    [AliasMethodChainTracer revertTracedAliasesAll];
    [super tearDown];
}

#pragma mark tests
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
    [self mockEmptyPostQueue];
    [self mockGetChangeLogDoesNothing];
    
    // Simulate redirection from AuthPage of the web site
    NSString *apiKey = @"ABCDEFG";
    NSString *userId = @"12345";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"items://sync/?key=%@&user_id=%@", apiKey, userId]];
    STAssertNoThrow([m_appDelegate application:[UIApplication sharedApplication] handleOpenURL:url], @"");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    STAssertEqualObjects([defaults objectForKey:@"ApiKey"], apiKey, @"");
    STAssertEqualObjects([defaults objectForKey:@"UserId"], userId, @"");
}

- (void)testPostInBox
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PostBulkChanges"];
    [self setupApiKey];
    // Post /api/changes will response id:10001
    [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock" withBlock:^(id _class, NSURL *url) {
        id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_requestWithURL:), url)];
        [[[mock stub] andDo:^(NSInvocation *invocation) {
            [[[mock stub] andReturnValue:[NSNumber numberWithInt:200]] responseStatusCode];
            [[[mock stub] andReturn:@"{\"id\": 10001}"] responseString];
            [mock requestFinished];
        }] startAsynchronous];
        return mock;
    }];
    [self mockGetChangeLogDoesNothing];
    
    STAssertNoThrow(objc_msgSend(m_listsViewController, @selector(sync)), @"");
    
    NSManagedObjectContext *context = m_appDelegate.managedObjectContext;
    id list = [context fetchFirstFromEntityName:@"List" withPredicateFormat:@"name == 'in-box'" argumentArray:[NSArray array]];
    STAssertEquals([[list valueForKey:@"id"] intValue], 10001, @"");
}

- (void)testPostChangesBulk
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PostBulkChanges"];
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"PostBulkChangesLimit"];
    [self setupApiKey];
    // Make 3 changes (-> total 4 new objects, including in-box)
    NSManagedObjectContext *context = m_appDelegate.managedObjectContext;
    //ItemList *inbox = [context fetchFirstFromEntityName:@"List" withPredicateFormat:@"name == 'in-box'" argumentArray:[NSArray array]];
    ItemList *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:context];
    [newList setValue:@"new list" forKey:@"name"];
    Item *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:context];
    [newItem setValue:@"new item" forKey:@"content"];
    Listing *listing = [NSEntityDescription insertNewObjectForEntityForName:@"Listing" inManagedObjectContext:context];
    [listing setValue:newList forKey:@"list"];
    [listing setValue:newItem forKey:@"item"];
    [context save];
    __block int countRequests = 0;
    [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock" withBlock:^(id _class, NSURL *url) {
        id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_requestWithURL:), url)];
        [[[mock stub] andDo:^(NSInvocation *invocation) {
            id bodyValue = [[[[NSString alloc] initWithData:[mock postBody] encoding:NSUTF8StringEncoding] autorelease] JSONValue];
            NSArray *changes = [bodyValue objectForKey:@"changes"];
            switch (countRequests++) {
            case 0:
                STAssertEquals([changes count], (NSUInteger)2, @"");
                [[[mock stub] andReturn:@"[{\"id\": 100}, {\"id\": 101}]"] responseString];
                break;
            case 1:
                STAssertEquals([changes count], (NSUInteger)2, @"");
                id itemValue = [[[changes objectAtIndex:0] objectForKey:@"json"] JSONValue];
                id listingValue = [[[changes objectAtIndex:1] objectForKey:@"json"] JSONValue];
                STAssertEquals([[listingValue objectForKey:@"list_id"] intValue], 101, @"");
                STAssertEqualObjects([listingValue objectForKey:@"item_uuid"], [itemValue objectForKey:@"uuid"], @"");
                [[[mock stub] andReturn:@"[{\"id\": 102}, {\"id\": 103}]"] responseString];
                break;
            default:
                STFail(@"");
            }
            [[[mock stub] andReturnValue:[NSNumber numberWithInt:200]] responseStatusCode];
            [mock requestFinished];
        }] startAsynchronous];
        return mock;
    }];
    [self mockGetChangeLogDoesNothing];
    
    STAssertNoThrow(objc_msgSend(m_listsViewController, @selector(sync)), @"");
    
    id record = nil;
    record = [context fetchFirstFromEntityName:@"List" withPredicateFormat:@"name == 'in-box'" argumentArray:[NSArray array]];
    STAssertEquals([[record valueForKey:@"id"] intValue], 100, @"");
    record = [context fetchFirstFromEntityName:@"List" withPredicateFormat:@"name == 'new list'" argumentArray:[NSArray array]];
    STAssertEquals([[record valueForKey:@"id"] intValue], 101, @"");
    record = [context fetchFirstFromEntityName:@"Item" withPredicateFormat:@"content == 'new item'" argumentArray:[NSArray array]];
    STAssertEquals([[record valueForKey:@"id"] intValue], 102, @"");
    record = [context fetchFirstFromEntityName:@"Listing" withPredicateFormat:@"id == 103" argumentArray:[NSArray array]];
    STAssertNotNil(record, @"");
}

- (void)testGetChangeLog_NewRecord
{
    [self setupApiKey];
    [self mockEmptyPostQueue];
    // GET /api/chageLog
    __block int countRequests = 0;
    [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock" withBlock:^(id _class, NSURL *url) {
        id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_requestWithURL:), url)];
        [[[mock stub] andDo:^(NSInvocation *invocation) {
            if (countRequests++ == 0) {
                [[[mock stub] andReturnValue:[NSNumber numberWithInt:200]] responseStatusCode];
                [[[mock stub] andReturn:@"{\"changed_at\":\"2011-04-18T00:14:05+0000\",\"created_at\":\"2011-04-18T00:14:05+0000\",\"id\":1324,\"json\":\"{\\\"user_id\\\":6,\\\"name\\\":\\\"foo\\\",\\\"updated_at\\\":\\\"2011-04-18T00:14:05+0000\\\",\\\"created_at\\\":\\\"2011-04-18T00:14:05+0000\\\",\\\"id\\\":19}\",\"record_id\":19,\"record_type\":\"List\",\"user_id\":6}"] responseString];
            } else {
                [[[mock stub] andReturnValue:[NSNumber numberWithInt:204]] responseStatusCode];
            }
            [mock requestFinished];
        }] startAsynchronous];
        return mock;
    }];
    
    STAssertNoThrow(objc_msgSend(m_listsViewController, @selector(sync)), @"");
    
    STAssertEquals(1324, [[NSUserDefaults standardUserDefaults] integerForKey:@"LastLogId"], @"");
    // verify new record
    id list = [m_appDelegate.managedObjectContext fetchFirstFromEntityName:@"List" withPredicateFormat:@"name == 'foo'" argumentArray:[NSArray array]];
    STAssertEquals(19, [[list valueForKey:@"id"] intValue], @"");
}

#pragma mark helper methods
- (void)setupApiKey
{
    // Set dummy ApiKey to avoid to get the key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"ABCDEFG" forKey:@"ApiKey"];
    [defaults setObject:@"12345" forKey:@"UserId"];
}

- (void)mockEmptyPostQueue
{
    //   Empty postQueue will not be processed
    [Synchronizer aliasClassMethod:@selector(singletonSynchronizer) chainingPrefix:@"mock" withBlock:^(id _class) {
        id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_singletonSynchronizer))];
        [[[mock stub] andReturn:[NSArray array]] postQueue];
        return mock;
    }];
}

// Skip actual GET /api/changes
- (void)mockGetChangeLogDoesNothing {
    [Synchronizer aliasInstanceMethod:@selector(getChangeLog) chainingPrefix:@"mock" withBlock:^(id _self) {
        [_self stop];
    }];
}

// //   GET /api/chageLog will be "204 No Content"
// - (void)mockNoCntentGetRequest
// {
//     [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"getNoContent" withBlock:^(id _class, NSURL *url) {
//         id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_getNoContent_requestWithURL:), url)];
//         [[[mock stub] andDo:^(NSInvocation *invocation) {
//             id requestMock = [invocation target];
//             [[[requestMock stub] andReturnValue:[NSNumber numberWithInt:204]] responseStatusCode];
//             [requestMock requestFinished];
//         }] startAsynchronous];
//         return mock;
//     }];
// }
@end
