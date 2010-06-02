#import "ItemsViewController.h"
#import "ItemsAppDelegate.h"
#if 1
#import "ItemContentEditingViewController.h"
#else
#import "ItemDetailViewController.h"
#endif
#import "Listing.h"

@implementation ItemsViewController

@synthesize list=m_list;

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    self.list = nil;
}

- (void)dealloc {
    [super dealloc];
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    NSLog(@"itemTable viewDidLoad");
    [super viewDidLoad];
    //self.navigationItem.title = @"Items";
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
#if 1
    // edit
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // toolbar new item button
    NSMutableArray *toolbarItems = [NSMutableArray array];
    self.toolbarItems = toolbarItems;
    //   spacer
    [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
    //   new item button
    [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newItem)] autorelease]];
#else
    // set Add button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];

    // edit button in toolbar
    self.toolbarItems = [[[NSArray alloc] initWithObjects:self.editButtonItem, nil] autorelease];
#endif
//     NSError *error = nil;
//     if (![self.fetchedResultsController performFetch:&error]) {
//         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//         abort();
//     }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.tableView reloadData];
    self.navigationItem.title = [self.list valueForKey:@"name"];

    // set srot order for listings
    NSFetchedPropertyDescription *fetchedDesc = [[[self.list entity] propertiesByName] objectForKey:@"fetchedListings"];
    NSFetchRequest *fetchRequest = [fetchedDesc fetchRequest];
    NSSortDescriptor *positionSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES] autorelease];
    NSSortDescriptor *createdSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO] autorelease];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:positionSortDescriptor, createdSortDescriptor, nil] autorelease];
    [fetchRequest setSortDescriptors:sortDescriptors];
    // eager loading listings.item
    [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"item"]];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

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
    return 1; //number of sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger count = [[self.list valueForKeyPath:@"fetchedListings"] count];
    NSLog(@"items count:%d", count);
    return count; //number of rows in section;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    cell.showsReorderControl = YES;
//    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //NSManagedObject *managedObject = [self.items anyObject]; //FIXME
    //[[self.list valueForKeyPath:@"listings.item"]]
    //cell.textLabel.text = [[managedObject valueForKey:@"content"] description];
    NSManagedObject *item = [[self.list valueForKeyPath:@"fetchedListings.item"] objectAtIndex:[indexPath row]];
    cell.textLabel.text = [[item valueForKey:@"content"] description];
    
    return cell;
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
        NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
        Listing *listing = [[self.list valueForKeyPath:@"fetchedListings"] objectAtIndex:[indexPath row]];
        //[context deleteObject:listing];
        [listing done];
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [context refreshObject:self.list mergeChanges:NO];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
#if 1
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger count = [[self.list valueForKeyPath:@"fetchedListings"] count];
    for (int i = 0; i < count; i++) {
        [array addObject:[NSNumber numberWithInt:i]];
    }
    [array removeObjectAtIndex:toIndexPath.row];
    [array insertObject:[NSNumber numberWithInt:toIndexPath.row] atIndex:fromIndexPath.row];
    int i=0;
    for (NSManagedObject *l in [self.list valueForKeyPath:@"fetchedListings"]) {
        [l setValue:[array objectAtIndex:i++] forKey:@"position"];
    }
#else
    NSMutableArray *listings = [[[self.list valueForKeyPath:@"fetchedListings"] mutableCopy] autorelease];
    NSManagedObject *listing = [[[listings objectAtIndex:fromIndexPath.row] retain] autorelease];
    [listings removeObjectAtIndex:fromIndexPath.row];
    [listings insertObject:listing atIndex:toIndexPath.row];
    int pos = 0;
    for (NSManagedObject *l in listings) {
        [l setValue:[NSNumber numberWithInt:pos++] forKey:@"position"];
    }
#endif
    [UIAppDelegate.managedObjectContext save];
    [UIAppDelegate.managedObjectContext refreshObject:self.list mergeChanges:NO];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *listing = [[self.list valueForKeyPath:@"fetchedListings"] objectAtIndex:[indexPath row]];
    NSManagedObject *item = [listing valueForKey:@"item"];
#if 1
//    ItemContentEditingViewController *itemController =[[ItemContentEditingViewController alloc] init];
    ItemContentEditingViewController *itemController = [[ItemContentEditingViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
#else
    ItemDetailViewController *itemController = [[[ItemDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
#endif
    itemController.list = self.list;
    itemController.item = item;
    itemController.delegate = self;
    [self.navigationController pushViewController:itemController animated:YES];
}
/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}
    */

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Done";
}

#pragma mark -
#pragma mark Add a new object

//REFACTOR: merge with -[ListsViewController newItem] if possible
- (void)newItem {
#if 1
//    ItemContentEditingViewController *itemController =[[ItemContentEditingViewController alloc] init];
    ItemContentEditingViewController *itemController = [[ItemContentEditingViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
#else
    ItemDetailViewController *itemController = [[[ItemDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
#endif
    itemController.list = self.list;
    itemController.delegate = self;
    //[self presentModalViewController:itemController animated:YES];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:itemController] autorelease];
    [self presentModalViewController:navigationController animated:YES];
}

//- (void)itemDetailViewController:(ItemDetailViewController *)itemDetailViewController didSaveItem:(NSManagedObject *)item {
- (void)itemContentEditingViewController:(ItemContentEditingViewController *)controller didSaveItem:(NSManagedObject *)item {
    [UIAppDelegate.managedObjectContext refreshObject:self.list mergeChanges:NO];
    [self.tableView reloadData];
    //REFACTOR: DRY with -[ItemDetailViewController back]
    if (self.parentViewController.modalViewController) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


/*
- (void)dismissModalViewControllerAnimated:(BOOL)animated {
    [super dismissModalViewControllerAnimated:animated];
    [UIAppDelegate.managedObjectContext refreshObject:self.list mergeChanges:NO];
    [self.tableView reloadData];
}
    */
/*
- (void)insertNewObject {
#if 0
    ItemViewController *itemController = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
//    itemController.list = self.list;
    [[self navigationController] pushViewController:itemController animated:YES];
    [itemController release];
#else
    ItemDetailViewController *itemController = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
    itemController.list = self.list;
    [[self navigationController] pushViewController:itemController animated:YES];
    [itemController release];
#endif
#if 0
    NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
    
    NSManagedObject *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                 inManagedObjectContext:context];
    [item setValue:@"hoge" forKey:@"content"];
    NSManagedObject *listing = [NSEntityDescription insertNewObjectForEntityForName:@"Listing"
                                                    inManagedObjectContext:context];
    [listing setValue:item forKey:@"item"];
    [[self.list mutableSetValueForKeyPath:@"listings"] addObject:listing];
    
    
    
//    [self.list
    //[self.items addObject: newManagedObject];
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    // refresh list.items
    [context refreshObject:self.list mergeChanges:NO];
    NSLog(@"TODO: transit to Item detail view");
#endif
}
    */
@end

