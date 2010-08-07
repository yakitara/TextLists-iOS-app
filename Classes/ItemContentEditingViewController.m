#import "ItemContentEditingViewController.h"
#import "ItemsAppDelegate.h"
#import "ListsViewController.h"
#import "Listing.h"
#import "Item.h"
#import "NSManagedObjectContextCategories.h"
#import "NSManagedObjectCategories.h"

/*
enum {
    SEGMENT_LIST = 0,
    SEGMENT_SAVE = 1
};
*/

@interface ItemContentEditingViewController ()
- (void)save;
- (void)cancel;
- (void)back;
@end

@implementation ItemContentEditingViewController
@synthesize item = m_item;
@synthesize list = m_list;
@synthesize delegate = m_delegate;
//@synthesize segmented = m_segmented;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)updateListView {
    NSString *title = [NSString stringWithFormat:@"list: %@", [self.list valueForKey:@"name"]];
    [m_listButton setTitle:title forState:UIControlStateNormal];
}

#if 1
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.item) {
        NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
        self.item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                         inManagedObjectContext:context];
        // show keyboard for new item
        [m_textView becomeFirstResponder];
    }
    
    // cancel button
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)] autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;
    //   save button
    UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)] autorelease];
    self.navigationItem.rightBarButtonItem = button;
    
    // represent item and list
    [m_textView setText:[self.item valueForKey:@"content"]];
    [self updateListView];
    [self textViewDidChange:m_textView];

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardWasShown:)
                                          name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardWasHidden:)
                                          name:UIKeyboardDidHideNotification object:nil];
}
#else
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    UITextView *view = [[UITextView alloc] init];
    view.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.view = view;
    [view release];
    // cancel button
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(back)] autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;
    // disable back
    //self.navigationItem.hidesBackButton = YES;
#if 1
    NSArray *segments = [NSArray arrayWithObjects: @"list:in-box", @"save", nil];
    UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems: segments] autorelease];
    self.segmented = segmentedControl;
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    CGSize size = [@"save" sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
    [segmentedControl setWidth:size.width + 8 forSegmentAtIndex:SEGMENT_SAVE];
    UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
#else
    //   save button
    UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)] autorelease];
    self.navigationItem.rightBarButtonItem = button;
#endif
/*  
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                       target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardWasShown:)
                                          name:UIKeyboardDidShowNotification object:nil];
    */
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                          selector:@selector(keyboardWasHidden:)
//                                          name:UIKeyboardDidHideNotification object:nil];
}
#endif

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
/*
    NSString *title = [NSString stringWithFormat:@"list:%@", [self.list valueForKey:@"name"]];
    CGFloat maxWidth = 200;
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    NSString *truncatedTitle = [title stringByTruncatingStringWithFont:font forWidth:maxWidth lineBreakMode:UILineBreakModeClip];
    [self.segmented setTitle:truncatedTitle forSegmentAtIndex:SEGMENT_LIST];
    CGSize size = [truncatedTitle sizeWithFont:font];
    [self.segmented setWidth:(maxWidth > size.width ? size.width : maxWidth)  + 8 forSegmentAtIndex:SEGMENT_LIST];
*/
#if 0 // to fix layout in case of chenged list
    [self.navigationController.navigationBar setNeedsDisplay];
    [self.navigationController.navigationBar setNeedsLayout];
//    [self.segmented setNeedsLayout];
//    [self.navigationController.navigationBar layoutSubviews];
    //self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:self.segmented] autorelease];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
#endif
    [self.navigationController setToolbarHidden:YES animated:NO];

#if 1
//    [m_textView becomeFirstResponder];
//    [m_textView setSelectedRange:NSMakeRange(0, 0)];
#else
    [self.view becomeFirstResponder];
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    // move cursor to the top of text
//    [m_textView setSelectedRange:NSMakeRange(0, 0)];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    //[self.item setValue:[m_textView text] forKey:@"content"];
}
*/
/*
- (void)segmentAction:(id)sender
{
    //NSLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
    switch ([sender selectedSegmentIndex]) {
    case SEGMENT_LIST:
        [self changeList];
        break;
    case SEGMENT_SAVE:
        [self save];
        break;
    }
}
*/

- (IBAction)changeList:(id)sender {
    ListsViewController *listsController = [[[ListsViewController alloc] init] autorelease];
    listsController.delegate = self;
    listsController.checkedList = self.list;
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:listsController] autorelease];
    [self presentModalViewController:navController animated:YES];
}

- (void)save {
    NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
    // refresh not new object to avoid NSUnderlyingException = Cannot update object that was never inserted.;
    if (![[self.item objectID] isTemporaryID]) {
        // to refresh result of fetchedListings
        [context refreshObject:self.item mergeChanges:NO];
    }
    [self.item setValue:[m_textView text] forKey:@"content"];
    Listing *listing = [[self.item valueForKey:@"listings"] anyObject];
    if (!listing) {
        listing = [NSEntityDescription insertNewObjectForEntityForName:@"Listing" inManagedObjectContext:context];
        //[[self.item valueForKey:@"listings"] addObject:listing];
        [listing setValue:self.item forKey:@"item"];
    } else if (![[listing valueForKey:@"list"] isEqual:self.list]) { // if list is changed
        [listing setValue:[NSNumber numberWithInt:0] forKey:@"position"];
    }

    [listing setValue:self.list forKey:@"list"];
//     Listing *lastListing = [[self.item valueForKey:@"fetchedListings"] lastObject];
//     // remove lastListing if list is changed
//     if (![self.list isIdentical:[lastListing valueForKey:@"list"]]) {
//         [lastListing done];
//         NSManagedObject *listing = [NSEntityDescription insertNewObjectForEntityForName:@"Listing" inManagedObjectContext:context];
//         [listing setValue:self.item forKey:@"item"];
//         //[listing setTimestamps];
//         [[self.list mutableSetValueForKeyPath:@"listings"] addObject:listing];
//     }
    
    [context save];
    [context refreshObject:self.list mergeChanges:NO];
    // back where from
    if ([self.delegate respondsToSelector:@selector(itemContentEditingViewController:didSaveItem:)]) {
        [self.delegate itemContentEditingViewController:self didSaveItem:self.item];
    } else {
        [self back];
    }
}

- (void)cancel {
    NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
    [context rollback];
    [self back];
}

- (void)back {
    //TODO: re-think away to check modal
    if (self.parentViewController.parentViewController.modalViewController) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)listsViewController:(ListsViewController *)listsController didCheckList:(NSManagedObject *)list {
    self.list = list;
    [self updateListView];
    [self dismissModalViewControllerAnimated:YES];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.list = nil;
    self.item = nil;
//    self.segmented = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UITextView delegate methods
- (void)textViewDidChange:(UITextView *)textView {
    NSInteger count = [Item contentMaxLength] - [textView.text length];
    [m_characterCounterLabel setText:[NSString stringWithFormat:@"%d", count]];
    [m_characterCounterLabel setHighlighted:(count < 0)];
    //[self.item setValue:[textView text] forKey:@"content"];
    NSError *error;
    NSString *value = [textView text];
    self.navigationItem.rightBarButtonItem.enabled = [self.item validateValue:&value forKey:@"content" error:&error];
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
#if 0
    CGRect viewFrame = [m_textView frame];
    viewFrame.size.height -= keyboardSize.height;
    [m_textView setFrame:viewFrame];
#else
    CGRect viewFrame = [self.view frame];
    viewFrame.size.height -= keyboardSize.height;
    self.view.frame = viewFrame;
#endif
/* 
    // Scroll the active text field into view.
    CGRect textFieldRect = [activeField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
    */
    keyboardShown = YES;
}

- (void)keyboardWasHidden:(NSNotification*)aNotification {
    keyboardShown = NO;
}
@end
