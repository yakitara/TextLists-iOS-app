#import <UIKit/UIKit.h>

@interface ItemDetailViewController : UITableViewController {
    NSManagedObject *_list;
    NSManagedObject *_item;
    UITextView *_textView;
    CGFloat keyboardHeight;
}

@property (nonatomic, retain) NSManagedObject *list;
@property (nonatomic, retain) NSManagedObject *item;
@property (nonatomic, retain) UITextView *textView;

@end
