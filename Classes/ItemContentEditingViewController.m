    //
//  ItemContentEditingViewController.m
//  ItemsCoreData
//
//  Created by hiroshi on 10/05/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemContentEditingViewController.h"


@implementation ItemContentEditingViewController
@synthesize item=_item;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    UITextView *view = [[UITextView alloc] init];
    view.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.view = view;
    [view becomeFirstResponder];
    [view release];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                       target:self action:@selector(edited)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardWasShown:)
                                          name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                          selector:@selector(keyboardWasHidden:)
//                                          name:UIKeyboardDidHideNotification object:nil];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((UITextView *)self.view).text = [self.item valueForKey:@"content"];
}

-(void)edited {
    [self.item setValue:((UITextView *)self.view).text forKey:@"content"];
    [self.navigationController popViewControllerAnimated:YES];
}




/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark keyboard notifications

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (keyboardShown)
        return;
 
    NSDictionary* info = [aNotification userInfo];
 
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
 
    // Resize the scroll view (which is the root view of the window)
    CGRect viewFrame = [self.view frame];
    viewFrame.size.height -= keyboardSize.height;
    self.view.frame = viewFrame;
/* 
    // Scroll the active text field into view.
    CGRect textFieldRect = [activeField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
    */
    keyboardShown = YES;
}

@end
