#import <UIKit/UIKit.h>
#import "ItemDetailViewController.h"

@interface ItemsViewController : UITableViewController <ItemDetailDelegate> {
    NSManagedObject *m_list;
}
@property (nonatomic, retain) NSManagedObject *list;
@end
