#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import <objc/message.h>
#import "NSObject+AliasMethodChain.h"

#import "ItemsAppDelegate.h"
#import "ListsViewController.h"
#import "NSUserDefaults+.h"
#import "ASIHTTPRequest.h"
#import "Synchronizer.h"

// @implementation Synchronizer (Mock)
// + (id)mock_singletonSynchronizer {
//     id mock = [OCMockObject partialMockForObject:objc_msgSend(self, @selector(without_mock_singletonSynchronizer))];
//     [[[mock stub] andReturn:[NSArray array]] postQueue];
//     return mock;
// }
// @end

// @implementation ASIHTTPRequest (Mock)
// + (id)mock_requestWithURL:(NSURL *)url {
//     id mock = [OCMockObject partialMockForObject:objc_msgSend(self, @selector(without_mock_requestWithURL:), url)];
    
//     void (^startAsynchronousBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
//         id requestMock = [invocation target];
//         [[[requestMock stub] andReturnValue:[NSNumber numberWithInt:204]] responseStatusCode];
//         //[[[requestMock stub] andReturnValue:@""] responseString];
//         //[requestMock setUserInfo:[NSDictionary dictionaryWithObject:]]
//         [requestMock requestFinished];
//     };
//     [[[mock stub] andDo:startAsynchronousBlock] startAsynchronous];
//     return mock;
// }
// @end

@interface TextListsTests : SenTestCase {
@private
    ItemsAppDelegate *m_appDelegate;
    ListsViewController *m_listsViewController;
}

@end

@implementation TextListsTests
// - (void)invokeTest {
//     @throw @"invokeTest";
//     //STAssertNoThrow([super invokeTest], @"");
//     @try {
//          [super invokeTest];
//      } @catch (id e) {
//         STFail(@"exception: %@", e);
//     //     //[self failWithException:e];
//     //     // [self failWithException:[NSException failureInFile:[NSString stringWithUTF8String:__FILE__]
//     //     //                                             atLine:__LINE__
//     //     //                                    withDescription:@"%@", e]];
//     }
// }

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    NSLog(@"setup");
    [NSUserDefaults resetToAppDefaults];
    m_appDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(m_appDelegate, @"Cannot find the application delegate");
    m_listsViewController = (ListsViewController *)m_appDelegate.navigationController.topViewController;
}

- (void)tearDown
{
    // Tear-down code here.
    NSLog(@"tearDown");
    [super tearDown];
}

#if 1
- (void)testSyncWithoutApiKey
{
    id appMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    [[appMock expect] openURL:[NSURL URLWithString:@"http://textlists.yakitara.com:8080/api/key?r=items://sync/"]];
    
    objc_msgSend(m_listsViewController, @selector(sync));
    
    [appMock verify];
}

- (void)testSettingApiKey
{
    [Synchronizer aliasClassMethod:@selector(singletonSynchronizer) chainingPrefix:@"mock" withBlock:^(id _class) {
        id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_singletonSynchronizer))];
        [[[mock stub] andReturn:[NSArray array]] postQueue];
        return mock;
    }];
    [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock" withBlock:^(id _class, NSURL url) {
        id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_requestWithURL:), url)];
        
        void (^startAsynchronousBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
            id requestMock = [invocation target];
            [[[requestMock stub] andReturnValue:[NSNumber numberWithInt:204]] responseStatusCode];
            //[[[requestMock stub] andReturnValue:@""] responseString];
            //[requestMock setUserInfo:[NSDictionary dictionaryWithObject:]]
            [requestMock requestFinished];
        };
        [[[mock stub] andDo:startAsynchronousBlock] startAsynchronous];
        return mock;
    }];
    
    NSString *apiKey = @"ABCDEFG";
    NSString *userId = @"12345";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"items://sync/?key=%@&user_id=%@", apiKey, userId]];
    STAssertNoThrow([m_appDelegate application:[UIApplication sharedApplication] handleOpenURL:url], @"");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    STAssertEqualObjects(apiKey, [defaults objectForKey:@"ApiKey"], @"");
    STAssertEqualObjects(userId, [defaults objectForKey:@"UserId"], @"");
    
    [ASIHTTPRequest revertAliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock"];
    [Synchronizer revertAliasClassMethod:@selector(singletonSynchronizer) chainingPrefix:@"mock"];
}

// - (void)testPostChangeLog
// {
//     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//     [defaults setObject:@"ABCDEFG" forKey:@"ApiKey"];
//     [defaults setObject:@"12345" forKey:@"UserId"];
    
//     [Synchronizer aliasClassMethod:@selector(singletonSynchronizer) chainingPrefix:@"mock" withBlock:^(id _class) {
//         id mock = [OCMockObject partialMockForObject:objc_msgSend(_class, @selector(without_mock_singletonSynchronizer))];
//         [[[mock stub] andReturn:[NSArray arrayWithObject:@"record"]] postQueue];
//         return mock;
//     }];
    
//     STAssertNoThrow(objc_msgSend(m_listsViewController, @selector(sync)), @"");
// }
#else
- (void)testFail
{
    NSLog(@"defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
//    NSLog(@"arguments: %@", [[NSUserDefaults standardUserDefaults] volatileDomainForName:@"NSArgumentDomain"]);
//    NSLog(@"volitile domains: %@", [[NSUserDefaults standardUserDefaults] volatileDomainNames]);
    STFail(@"fail");
}
#endif
@end
