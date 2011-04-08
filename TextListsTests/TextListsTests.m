//
//  TextListsTests.m
//  TextListsTests
//
//  Created by hiroshi on 11/04/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextListsTests.h"


@implementation TextListsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testAppDelegate
{
    id appDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(appDelegate, @"Cannot find the application delegate");
//    STFail(@"Unit tests are not implemented yet in TextListsTests");
}

@end
