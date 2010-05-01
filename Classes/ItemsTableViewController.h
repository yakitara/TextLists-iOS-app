#import <UIKit/UIKit.h>


@interface ItemsTableViewController : UITableViewController {
//    NSFetchedResultsController *_fetchedResultsController;
//    NSManagedObjectContext *_managedObjectContext;
//    NSSet *_items;
//    NSMutableArray *_items;
    NSManagedObject *_list;
}

//@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *list;

@end
