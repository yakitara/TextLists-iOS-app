#import <UIKit/UIKit.h>


@interface ItemsTableViewController : UITableViewController {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *_managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
