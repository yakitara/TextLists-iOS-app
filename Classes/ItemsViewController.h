#import <UIKit/UIKit.h>
#import "ItemDetailViewController.h"

@interface ItemsViewController : UITableViewController <ItemDetailDelegate> {
    NSManagedObject *_list;
}

@property (nonatomic, retain) NSManagedObject *list;

@end
