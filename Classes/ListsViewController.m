#import "ListsViewController.h"
#import "ItemsViewController.h"
#import "ListDetailViewController.h"
#import "ItemsAppDelegate.h"
#import "NSManagedObjectContextCategories.h"
#import "UITableViewControllerCategories.h"
#import "ItemList.h"
#import "Listing.h"
#import "Synchronizer.h"
#import "ItemContentEditingViewController.h"

@interface ListsViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation ListsViewController
//@synthesize fetchedResultsController = m_fetchedResultsController;
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
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newList)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    if (!self.checkedList) {
        // toolbar items
        NSMutableArray *toolbarItems = [NSMutableArray array];
        self.toolbarItems = toolbarItems;
        //   sync item button
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(sync)] autorelease]];
        //   syncActivityIndicator
        UIActivityIndicatorView *activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        activityIndicator.hidesWhenStopped = YES;
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithCustomView:activityIndicator] autorelease]];
        UIAppDelegate.syncActivityIndicator = activityIndicator;
        //   spacer
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
        //   new item button
        [toolbarItems addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newItem)] autorelease]];
    }
#if 1
    [UIAppDelegate.listsFetchedResultsController addTableView:self.tableView];
//    self.fetchedResultsController = UIAppDelegate.listsFetchedResultsController;
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
    // To avoid inconsistency of list order between the view and the data when
    // a list is added, force to refresh the table view.
    [self.tableView reloadData];
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
    if (self.checkedList) {
        if ([[self.checkedList objectID] isEqual:[managedObject objectID]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}


#pragma mark -
#pragma mark Actions

- (void)newList {
    ListDetailViewController *listController = [[ListDetailViewController alloc] initWithNibName:@"ListDetailViewController" bundle:nil];
    [[self navigationController] pushViewController:listController animated:YES];
    [listController release];
}

- (void)newItem {
    ItemContentEditingViewController *itemController = [[[ItemContentEditingViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    itemController.list = self.inbox;
    //[self presentModalViewController:itemController animated:YES];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:itemController] autorelease];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)sync {
    [Synchronizer sync];
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
#if 1
        ItemList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSDate *date = [NSDate date];
        [list setValue:date forKey:@"deleted_at"];
        for (Listing *listing in [list valueForKey:@"listings"]) {
            [listing setValue:date forKey:@"deleted_at"];
        }
#else
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
#endif
        [context save];
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSArray *array = [self reorderedArrayAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    int i=0;
    for (NSManagedObject *l in self.fetchedResultsController.fetchedObjects) {
        NSLog(@"row:%@ -> %@", [l valueForKey:@"position"], [array objectAtIndex:i]);
        [l setValue:[array objectAtIndex:i++] forKey:@"position"];
    }
    [UIAppDelegate.managedObjectContext save];
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
- (NSFetchedResultsController *)fetchedResultsController {
    return UIAppDelegate.listsFetchedResultsController;
}

- (NSManagedObject*)inbox {
    if (!m_inbox) {
        NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
        BOOL saveAllowed = ![context hasChanges];
        for (NSManagedObject *list in [self.fetchedResultsController fetchedObjects]) {
            NSString *listName = [list valueForKey:@"name"];
            if ([listName compare:@"in-box"] == NSOrderedSame) {
                self.inbox = list;
                return m_inbox;
            }
        }
        self.inbox = [NSEntityDescription insertNewObjectForEntityForName:@"List"
                                          inManagedObjectContext:context];
        [self.inbox setValue:@"in-box" forKey:@"name"];
        //[self.inbox setTimestamps];
        if (saveAllowed) {
            [context save];
        }
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
    [UIAppDelegate.listsFetchedResultsController removeTableView:self.tableView];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [super viewDidUnload];
}


- (void)dealloc {
    [UIAppDelegate.listsFetchedResultsController removeTableView:self.tableView];
    //self.fetchedResultsController = nil;
    self.inbox = nil;
    self.checkedList = nil;
    //self.fetchedResultsController = nil;
    //[self viewDidUnload];
    [super dealloc];
}


@end

