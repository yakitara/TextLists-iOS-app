#import "DelegatingFetchedResultsController.h"


@implementation DelegatingFetchedResultsController
//@synthesize tableViews=m_tableViews;

- (NSMutableArray *)tableViews {
    if (!m_tableViews) {
        m_tableViews = [[NSMutableArray alloc] init];
    }
    return m_tableViews;
}

- (void)addTableView:(UITableView *)tableView {
    [self.tableViews addObject:tableView];
}

- (void)removeTableView:(UITableView *)tableView {
    [self.tableViews removeObject:tableView];
}

// - (id)retain {
//     return [super retain];
// }

- (void)dealloc {
    [m_tableViews release];
    [super dealloc];
}

#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    for (UITableView *tableView in self.tableViews) {
        [tableView beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    for (UITableView *tableView in self.tableViews) {
        switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    for (UITableView *tableView in self.tableViews) {
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
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    for (UITableView *tableView in self.tableViews) {
        [tableView endUpdates];
    }
}

@end
