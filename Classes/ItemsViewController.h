#import <UIKit/UIKit.h>


@interface ItemsViewController : UITableViewController {
    NSManagedObject *_list;
}

@property (nonatomic, retain) NSManagedObject *list;

@end
