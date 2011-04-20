// ;-*-ObjC-*-
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@protocol ListsViewControllerDelegate;

@interface ListsViewController : UITableViewController {
    //NSFetchedResultsController *m_fetchedResultsController;
    NSManagedObject *m_inbox;
    NSManagedObject *m_checkedList;
    id <ListsViewControllerDelegate> m_delegate;
}

@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObject *inbox;
@property (nonatomic, retain) NSManagedObject *checkedList;
@property (nonatomic, assign) id <ListsViewControllerDelegate> delegate;
@end

@protocol ListsViewControllerDelegate <NSObject>
- (void)listsViewController:(ListsViewController *)listsController didCheckList:(NSManagedObject *)list;
@end
