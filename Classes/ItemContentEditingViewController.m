#import "ItemContentEditingViewController.h"
#import "ItemsAppDelegate.h"

enum {
    SEGMENT_LIST = 0,
    SEGMENT_SAVE = 1
};

@interface ItemContentEditingViewController ()
- (void)changeList;
- (void)back;
- (void)save;
@end

@implementation ItemContentEditingViewController
@synthesize item=m_item, list=m_list, delegate=m_delegate, segmented=m_segmented;
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
    [view release];
    // cancel button
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(back)] autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;
    // disable back
    //self.navigationItem.hidesBackButton = YES;
#if 1    
    NSArray *segments = [NSArray arrayWithObjects: @"label", @"save", nil];
    UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems: segments] autorelease];
    self.segmented = segmentedControl;
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.item) {
        NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
        self.item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                         inManagedObjectContext:context];
    }
    ((UITextView *)self.view).text = [self.item valueForKey:@"content"];
    [self.segmented setTitle:[NSString stringWithFormat:@"list:%@", [self.list valueForKey:@"name"]] forSegmentAtIndex:SEGMENT_LIST];
    [self.view becomeFirstResponder];
}
/*
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    [self.item setValue:((UITextView *)self.view).text forKey:@"content"];
}
*/

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

- (void)changeList {
    
}

- (void)save {
    NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
    [self.item setValue:((UITextView *)self.view).text forKey:@"content"];
    if ([[self.item objectID] isTemporaryID]) {
        NSManagedObject *listing = [NSEntityDescription insertNewObjectForEntityForName:@"Listing" inManagedObjectContext:context];
        [listing setValue:self.item forKey:@"item"];
#if 0
        int position = [[[[self.list valueForKey:@"fetchedListings"] lastObject] valueForKey:@"position"] intValue] + 1;
        [listing setValue:[NSNumber numberWithInt:position] forKey:@"position"];
#endif
        [listing setTimestamps];
        [[self.list mutableSetValueForKeyPath:@"listings"] addObject:listing];
    }
    [self.item setTimestamps];
    [context save];
    [context refreshObject:self.list mergeChanges:NO];
    
//    [self.navigationController popViewControllerAnimated:YES];
    // back where from
    if ([self.delegate respondsToSelector:@selector(itemContentEditingViewController:didSaveItem:)]) {
        [self.delegate itemContentEditingViewController:self didSaveItem:self.item];
    } else {
        [self back];
    }
}

- (void)back {
    //TODO: re-think away to check modal
    if (self.parentViewController.parentViewController.modalViewController) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    self.list = nil;
    self.item = nil;
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
