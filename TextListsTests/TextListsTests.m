#import <SenTestingKit/SenTestingKit.h>
//#import <OCMock/OCMock.h>

#import "ItemsAppDelegate.h"
#import "ListsViewController.h"
#import <objc/message.h>

@interface TextListsTests : SenTestCase {
@private
    ItemsAppDelegate *m_appDelegate;
    ListsViewController *m_listsViewController;
}

@end

@implementation TextListsTests
- (void)setUp
{
    [super setUp];
    // Set-up code here.
    NSLog(@"setup");
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

- (void)testSyncInvokeOAuth
{
    // id appMock = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    // [[[appMock expect] andForwardToRealObject] openURL:[NSURL URLWithString:@"http://example.com"]];

    objc_msgSend(m_listsViewController, @selector(sync));
}
@end
