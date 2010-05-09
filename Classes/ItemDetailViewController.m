#import "ItemDetailViewController.h"
#import "ItemsAppDelegate.h"
#import "ItemContentEditingViewController.h"


@implementation ItemDetailViewController
@synthesize list=_list, item=_item;
@synthesize contentLabel=_contentLabel;

#pragma mark -
#pragma mark helper methods
#define fontSize (18.0f)

- (CGFloat)contentHeightWithString:(NSString *)string {
#if 1
    return self.view.frame.size.height - self.tableView.rowHeight - 30;// - keyboardHeight;// - 200;
#else
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 50;
    CGFloat maxHeight = 9999;
    CGSize maximumLabelSize = CGSizeMake(maxWidth,maxHeight);
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGSize labelSize = [string sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height;
#endif
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // multiline content cell
#if 1
    UITextView *cellLabel = [[UITextView alloc] init];//WithFrame:CGRectMake(0,0,320,480)];
    cellLabel.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cellLabel.scrollEnabled = NO;
    cellLabel.delegate = self;
#else
    UILabel *cellLabel = [[UILabel alloc] init];
    cellLabel.textColor = [UIColor blackColor];
    cellLabel.backgroundColor = [UIColor clearColor];
    cellLabel.textAlignment = UITextAlignmentLeft;
    cellLabel.font = [UIFont systemFontOfSize:fontSize];
    cellLabel.numberOfLines = 0; 
#endif
    [cellLabel sizeToFit];
    self.contentLabel = cellLabel;
    [cellLabel release];
    // save button
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                       target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
/*    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardWasShown:)
                                          name:UIKeyboardDidShowNotification object:nil];
    */    
    //self.tableView.backgroundColor = [UIColor darkGrayColor];
    
/*
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    */
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.item) {
        NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
        self.item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                         inManagedObjectContext:context];
    }

    NSString *text = [self.item valueForKey:@"content"];
    self.contentLabel.text = text;
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 50;
    CGFloat height = [self contentHeightWithString:text];// + 10.0;
    self.contentLabel.frame = CGRectMake(10.0f, 10.0f, width, height);

#if 0
    self.view.frame.height -

    self.contentLabel.frame = CGRectMake(0, 0, 320, 480);
#endif
//    [self.contentLabel becomeFirstResponder];
//    [self.tableView reloadData];
    
    //self.view.frame = CGRectMake(0,0,320,200);
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1; //<#number of sections#>;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2; //<#number of rows in section#>;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return self.contentCell;
    UITableViewCell *cell = nil;
    switch ([indexPath row]) {
    case 0: {
        NSString *CellIdentifier = @"Default2";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"List";
        cell.detailTextLabel.text = [self.list valueForKey:@"name"];//FIXME: use [item.labels anyObject].name
        break;}
    case 1: {
        NSString *CellIdentifier = @"Default";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
/*
        {
            NSLog(@"contentView.frame.org[%f,%f]",cell.contentView.frame.origin.x, cell.contentView.frame.origin.y);
            NSLog(@"contentView.bounds.org[%f,%f]",cell.contentView.bounds.origin.x, cell.contentView.bounds.origin.y);
        }
    */
/*
        NSString *text = [self.item valueForKey:@"content"];
        self.contentLabel.text = text;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 50;
        CGFloat height = [self contentHeightWithString:text];// + 10.0;
        self.contentLabel.frame = CGRectMake(10.0f, 10.0f, width, height);
    */
        [cell.contentView addSubview:self.contentLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

/*
        UITextView *textView = self.contentLabel;
        CGFloat fontHeight = (textView.font.ascender - textView.font.descender) + 1;
        CGRect newTextFrame = textView.frame;
        newTextFrame.size = textView.contentSize;
        newTextFrame.size.height = newTextFrame.size.height + fontHeight;
        textView.frame = newTextFrame;
        //
        CGRect newCellFrame = textView.superview.superview.frame;
        newCellFrame.size.height = newTextFrame.size.height + 20;
        textView.superview.superview.frame = newCellFrame;
    */        

//         cell.textLabel.numberOfLines = 0;
//         cell.textLabel.text = @"a\nb\nc\nd\n";
        //cell = _contentCell;
/*
        UITextView *textView = [[[UITextView alloc] initWithFrame:CGRectMake(0,0,200,200)] autorelease];
        cell.frame = CGRectMake(0,0,cell.frame.size.width,200);
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:textView];
    */
//        [cell.contentView addSubview:self.contentView];
        break;}
    }
    //cell.backgroundColor = [UIColor whiteColor];
    //cell.opaque = YES;
    NSLog(@"cellForRowAtIndexPath:%@", indexPath);
    return cell;
}

-(void)save {
    NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
    NSManagedObject *listing = [NSEntityDescription insertNewObjectForEntityForName:@"Listing"
                                                    inManagedObjectContext:context];
    [listing setValue:self.item forKey:@"item"];
    [[self.list mutableSetValueForKeyPath:@"listings"] addObject:listing];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    // refresh list.items
    [context refreshObject:self.list mergeChanges:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
    case 1: {
        ItemContentEditingViewController *controller =[[ItemContentEditingViewController alloc] init];
        controller.item = self.item;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        break; }
    }
    
    
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = tableView.rowHeight;
    //CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    switch ([indexPath row]) {
    case 1: {
        height = [self contentHeightWithString:[self.item valueForKey:@"content"]] + 20.0;
//        height = 200;
        /*
        //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //FIXME: maybe inefficient
        CGSize size = [cell.textLabel.text sizeWithFont:cell.textLabel.font
                           constrainedToSize:CGSizeMake(cell.textLabel.bounds.size.width, 2000)
                           lineBreakMode:UILineBreakModeWordWrap];
        height = size.height;
            */
        //[tableView cellForRowAtIndexPath:indexPath].contentView
        /*
        NSLog(@"view:%@",self.contentView);
        NSLog(@"  bounds.height:%f",self.contentView.bounds.size.height);
        height = self.contentView.bounds.size.height;
            */
        break; }
    }
    NSLog(@"heightForRowAtIndexPath:%@ => %f",indexPath, height);
    return height;
}




#pragma mark -
#pragma mark Actions
//TODO: Add validation for empty name
/*
- (IBAction)contentDidEnter:(id)sender {
    NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                             inManagedObjectContext:context];
    [newManagedObject setValue: self.textView.text forKey:@"content"];
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    // refresh list.items
    [context refreshObject:self.list mergeChanges:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}
    */
/*
-(CGRect)contentCellHeight {
    NSLog(@"textViewDidChange");
    CGFloat fontHeight = (textView.font.ascender - textView.font.descender) + 1;

    CGRect newTextFrame = textView.frame;
    newTextFrame.size = textView.contentSize;
    return newTextFrame.size.height + fontHeight;
}
    */
-(void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
#if 1
    CGFloat fontHeight = (textView.font.ascender - textView.font.descender) + 1;

    CGRect newTextFrame = textView.frame;
    newTextFrame.size = textView.contentSize;
    newTextFrame.size.height = newTextFrame.size.height + fontHeight;
    textView.frame = newTextFrame;
    //
    CGRect newCellFrame = textView.superview.superview.frame;
    newCellFrame.size.height = newTextFrame.size.height + 20;
    textView.superview.superview.frame = newCellFrame;
    //
    //[self.tableView reloadData];
    //[self.tableView _updateContentSize];
    //[self.tableView setNeedsDisplay];
#endif
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma mark keyboard notifications
#if 0
- (void)keyboardWasShown:(NSNotification*)aNotification
{
//    if (keyboardHeight)
        return;
    NSDictionary* info = [aNotification userInfo];
//    NSLog(@"self.view:%@",self.view);
//    NSLog(@"self.view:%@",self.view);
 
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    keyboardHeight = keyboardSize.height;
    // Resize the scroll view (which is the root view of the window)
    CGRect viewFrame = self.view.superview.frame;
//    CGRect viewBounds = [self.view bounds];
    //viewFrame.origin.y -= keyboardHeight;
    viewFrame.size.height -= keyboardHeight;
    self.view.superview.frame = viewFrame;
//     viewBounds.size.height -= keyboardHeight;
//     self.view.bounds = viewBounds;
    NSLog(@"keyboardShown:%f",viewFrame.size.height);
/*
    CGSize contentSize = self.tableView.contentSize;
    contentSize.height -= keyboardSize.height;
    self.tableView.contentSize = contentSize;
    */
//    [self.tableView reloadData];
//    [self.contentLabel becomeFirstResponder];
    //[self.view setNeedsDisplay];
/* 
    // Scroll the active text field into view.
    CGRect textFieldRect = [activeField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
    */
//    keyboardShown = YES;
}
#endif
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.list = nil;
    self.item = nil;
    self.contentLabel = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

