// ;-*-ObjC-*-
#import <UIKit/UIKit.h>
//#import "ItemDetailViewController.h"
#import "ItemContentEditingViewController.h"

@interface ItemsViewController : UITableViewController <ItemContentEditingDelegate> {
    NSManagedObject *m_list;
}
@property (nonatomic, retain) NSManagedObject *list;
@end
