#import "ListsViewController.h"
#import "ItemsViewController.h"
#import "ListDetailViewController.h"
#import "ItemsAppDelegate.h"
#if 1
#import "ItemContentEditingViewController.h"
#else
#import "ItemDetailViewController.h"
#endif

@interface ListsViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation ListsViewController
@synthesize fetchedResultsController = m_fetchedResultsController;
@synthesize inbox = m_inbox;
@synthesize checkedList = m_checkedList;
@synthesize delegate = m_delegate;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // set the title
    self.navigationItem.title = @"Lists";
    // edit button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    // add button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    if (!self.checkedList) {
        // toolbar items
        NSMutableArray *toolbarItems = [NSMutableArray array];
        self.toolbarItems = toolbarItems;
        //   sync item button
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:UIAppDelegate action:@selector(sync)] autorelease]];
        //   spacer
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
        //   new item button
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newItem)] autorelease]];
    }
#if 1
    [UIAppDelegate.listsFetchedResultsController addTableView:self.tableView];
    self.fetchedResultsController = UIAppDelegate.listsFetchedResultsController;
#else
    // fetch lists
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
#endif
    // find or create inbox
    [self inbox];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:(self.checkedList ? YES : NO) animated:NO];
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
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
    if ([[self.checkedList objectID] isEqual:[managedObject objectID]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject {
   //TODO: initWithNibName でロードする
//    ListDetailViewController *listController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    ListDetailViewController *listController = [[ListDetailViewController alloc] initWithNibName:@"ListDetailViewController" bundle:nil];

//    itemsController.selectedRegion = [regions objectAtIndex:indexPath.row];
    [[self navigationController] pushViewController:listController animated:YES];
    [listController release];
    
/*    
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    */
}

- (void)newItem {
    //TODO: release itemController
#if 1
//    ItemContentEditingViewController *itemController =[[ItemContentEditingViewController alloc] init];
    ItemContentEditingViewController *itemController = [[ItemContentEditingViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
#else
    ItemDetailViewController *itemController = [[[ItemDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
#endif
    itemController.list = self.inbox;
    //[self presentModalViewController:itemController animated:YES];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:itemController] autorelease];
    [self presentModalViewController:navigationController animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.showsReorderControl = YES;
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
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
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableArray *lists = [[self.fetchedResultsController.fetchedObjects mutableCopy] autorelease];
    NSManagedObject *list = [[[lists objectAtIndex:fromIndexPath.row] retain] autorelease];
    [lists removeObjectAtIndex:fromIndexPath.row];
    [lists insertObject:list atIndex:toIndexPath.row];
    int pos = 0;
    for (NSManagedObject *l in lists) {
        NSLog(@"list(%@)", [l valueForKey:@"name"]);
        [l setValue:[NSNumber numberWithInt:pos++] forKey:@"position"];
    }
    [UIAppDelegate.managedObjectContext save];
    
    //NOTE: I don't believe that it is needed to perfoeme fetch, though to work around for editing status cells
    // after editing done.
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (!self.checkedList) {
        ItemsViewController *itemsController = [[ItemsViewController alloc] initWithStyle:UITableViewStylePlain];
        NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //NSSet *items = [selectedObject valueForKeyPath:@"listings.item"];
        //NSMutableArray *items = [selectedObject mutableArrayValueForKeyPath:@"listings.item"];
        itemsController.list = selectedObject;
        [[self navigationController] pushViewController:itemsController animated:YES];
        [itemsController release];
    } else {
        // uncheck last list
        NSIndexPath *lastIndexPath = [self.fetchedResultsController indexPathForObject:self.checkedList];
        UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:lastIndexPath];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
        // check new list
        UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedList = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([self.delegate respondsToSelector:@selector(listsViewController:didCheckList:)]) {
            [self.delegate listsViewController:self didCheckList: self.checkedList];
        } else {
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


#pragma mark -
#pragma mark Fetched results controller
/*
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    NSSortDescriptor *positionSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES] autorelease];
    NSSortDescriptor *createdSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:YES] autorelease];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:positionSortDescriptor, createdSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"List"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    //[sortDescriptor release];
    [sortDescriptors release];
    
    return _fetchedResultsController;
}    
*/
- (NSManagedObject*)inbox {
    if (!m_inbox) {
        for (NSManagedObject *list in [self.fetchedResultsController fetchedObjects]) {
            NSString *listName = [list valueForKey:@"name"];
            if ([listName compare:@"in-box"] == NSOrderedSame) {
                self.inbox = list;
                return m_inbox;
            }
        }
        NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
        self.inbox = [NSEntityDescription insertNewObjectForEntityForName:@"List"
                                          inManagedObjectContext:context];
        [self.inbox setValue:@"in-box" forKey:@"name"];
        [self.inbox setTimestamps];
        //NOTE: will be inserted at next save or destruction of context, end of the app
    }
    return m_inbox;
}

#pragma mark -
#pragma mark Fetched results controller delegate

/*
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}
*/

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [UIAppDelegate.listsFetchedResultsController removeTableView:self.tableView];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.fetchedResultsController = nil;
    self.inbox = nil;
    self.checkedList = nil;
}


- (void)dealloc {
    //self.fetchedResultsController = nil;
    [self viewDidUnload];
    [super dealloc];
}


@end

