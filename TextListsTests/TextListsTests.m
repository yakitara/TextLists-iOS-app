#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import <objc/message.h>
#import "NSObject+AliasMethodChain.h"

#import "ItemsAppDelegate.h"
#import "ListsViewController.h"
#import "NSUserDefaults+.h"
#import "ASIHTTPRequest.h"
#import "Synchronizer.h"

@implementation Synchronizer (Mock)
+ (id)mock_singletonSynchronizer {
    id mock = [OCMockObject partialMockForObject:objc_msgSend(self, @selector(without_mock_singletonSynchronizer))];
    [[[mock stub] andReturn:[NSArray array]] postQueue];
    return mock;
}
@end

@implementation ASIHTTPRequest (Mock)
+ (id)mock_requestWithURL:(NSURL *)url {
    id mock = [OCMockObject partialMockForObject:objc_msgSend(self, @selector(without_mock_requestWithURL:), url)];
    
    void (^startAsynchronousBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        id requestMock = [invocation target];
        [[[requestMock stub] andReturnValue:[NSNumber numberWithInt:204]] responseStatusCode];
        //[[[requestMock stub] andReturnValue:@""] responseString];
        //[requestMock setUserInfo:[NSDictionary dictionaryWithObject:]]
        [requestMock requestFinished];
    };
    [[[mock stub] andDo:startAsynchronousBlock] startAsynchronous];
    return mock;
}
@end

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

#if 0
- (void)testFail
{
    // NSLog(@"defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    // NSLog(@"arguments: %@", [[NSUserDefaults standardUserDefaults] volatileDomainForName:@"NSArgumentDomain"]);
    // NSLog(@"volitile domains: %@", [[NSUserDefaults standardUserDefaults] volatileDomainNames]);
    STFail(@"fail");
}
#else
- (void)testSyncWithoutApiKey
{
    id appMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    [[appMock expect] openURL:[NSURL URLWithString:@"http://textlists.yakitara.com:8080/api/key?r=items://sync/"]];
    
    objc_msgSend(m_listsViewController, @selector(sync));
    
    [appMock verify];
}

- (void)testSettingApiKey
{
    // id requestClassMock = (Class)[OCMockObject partialMockForObject:(id)[ASIHTTPRequest class]];
    // void (^theBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
    //     NSLog(@"requestWithURL:%@", invocation);
    // };
    // [[[requestClassMock stub] andDo:theBlock] requestWithURL:[OCMArg any]];

    [Synchronizer aliasClassMethod:@selector(singletonSynchronizer) chainingPrefix:@"mock"];
    [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock"];
    
    NSString *apiKey = @"ABCDEFG";
    NSString *userId = @"12345";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"items://sync/?key=%@&user_id=%@", apiKey, userId]];
    STAssertNoThrow([m_appDelegate application:[UIApplication sharedApplication] handleOpenURL:url], @"");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    STAssertEqualObjects(apiKey, [defaults objectForKey:@"ApiKey"], @"");
    STAssertEqualObjects(userId, [defaults objectForKey:@"UserId"], @"");
}
#endif
@end
