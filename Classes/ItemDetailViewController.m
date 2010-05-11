#import "ItemDetailViewController.h"
#import "ItemsAppDelegate.h"
#import "ItemContentEditingViewController.h"

@implementation ItemDetailViewController
@synthesize list=m_list, item=m_item;
@synthesize textView=m_textView;
@synthesize delegate=m_delegate;

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    self.list = nil;
    self.item = nil;
    self.textView = nil;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // text view in a cell
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 50;
    UITextView *textView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 1)] autorelease];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;// | UIViewAutoresizingFlexibleWidth;
    self.textView = textView;
    
    // cancel button
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)] autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;
    // save button
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.item) {
        NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
        self.item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                         inManagedObjectContext:context];
    }

    UITextView *textView = self.textView;
#if 0
    textView.text = @"foo00000000000000000000000000000000000000000000000000000000000000000000000000000000000000\nbar\nbaz";
#else
    textView.text = [self.item valueForKey:@"content"];
    NSLog(@"text:%@", textView.text);
#endif
/*
    NSString *text = [self.item valueForKey:@"content"];
    self.textView.text = text;
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 50;
    */    
//     CGFloat height = [self contentHeightWithString:text];// + 10.0;
//     self.textView.frame = CGRectMake(10.0f, 10.0f, width, height);
    
//    [self.textView becomeFirstResponder];
    [self.tableView reloadData];
    NSLog(@"viewWillAppear");
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
    
    // dismiss
    if ([self.delegate respondsToSelector:@selector(itemDetailViewController:didSaveItem:)]) {
        [self.delegate itemDetailViewController:self didSaveItem:self.item];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

-(void)cancel {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
/*
        {
            NSLog(@"textView.frame.org[%f,%f]",cell.textView.frame.origin.x, cell.textView.frame.origin.y);
            NSLog(@"textView.bounds.org[%f,%f]",cell.textView.bounds.origin.x, cell.textView.bounds.origin.y);
        }
    */
/*
        NSString *text = [self.item valueForKey:@"content"];
        self.textView.text = text;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 50;
        CGFloat height = [self contentHeightWithString:text];// + 10.0;
        self.textView.frame = CGRectMake(10.0f, 10.0f, width, height);
    */

        [cell.contentView addSubview:self.textView];
#if 1
        UITextView *textView = self.textView;
        CGRect frame = textView.frame;
        frame.origin.y = 10;
        textView.frame = frame;
#else
        UITextView *textView = self.textView;
        CGRect newTextFrame = textView.frame;
        //newTextFrame.size = textView.contentSize;
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 50;
        CGFloat maxHeight = 9999;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, maxHeight);
        CGSize labelSize = [textView.text sizeWithFont:textView.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        NSLog(@"labelSize[%f,%f]",labelSize.width,labelSize.height);
        newTextFrame.origin.y = 10;
        newTextFrame.size = labelSize;
        newTextFrame.size.width = maxWidth;
        newTextFrame.size.height += (textView.font.ascender - textView.font.descender) + 1;
//        textView.contentSize = newTextFrame.size;
        textView.frame = newTextFrame;
        NSLog(@"textHeight=%f\n", textView.frame.size.height);
#endif
        //[cell.textView sizeToFit];
//        [textView sizeToFit];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;

/*
        UITextView *textView = self.textView;
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
        [cell.textView addSubview:textView];
    */
//        [cell.textView addSubview:self.textView];
        break;}
    }
    //cell.backgroundColor = [UIColor whiteColor];
    //cell.opaque = YES;
    NSLog(@"cellForRowAtIndexPath:%@", indexPath);
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
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
    */


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
    //NSLog(@"didSelectRowAtIndexPath:%@", indexPath);
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
    switch ([indexPath row]) {
    case 1: {
        UITextView *textView = self.textView;
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 50;
        CGFloat maxHeight = 9999;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, maxHeight);
        CGSize labelSize = [textView.text sizeWithFont:textView.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        height = labelSize.height + (textView.font.ascender - textView.font.descender) + 20;
        break; }
    }
    //NSLog(@"heightForRowAtIndexPath:%@ => %f",indexPath, height);
    return height;
}

@end

