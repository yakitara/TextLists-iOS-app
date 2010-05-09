#import <UIKit/UIKit.h>

@interface ItemDetailViewController : UITableViewController {
    NSManagedObject *_list;
    NSManagedObject *_item;
    UILabel *_contentLabel;
    CGFloat keyboardHeight;
}

@property (nonatomic, retain) NSManagedObject *list;
@property (nonatomic, retain) NSManagedObject *item;
@property (nonatomic, retain) UILabel *contentLabel;

@end
