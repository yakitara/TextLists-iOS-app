#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ListsViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObject *_inbox;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObject *inbox;

@end
