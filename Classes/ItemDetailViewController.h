// ;-*-ObjC-*-
#import <UIKit/UIKit.h>
@protocol ItemDetailDelegate;

@interface ItemDetailViewController : UITableViewController {
    NSManagedObject *m_list;
    NSManagedObject *m_item;
    UITextView *m_textView;
    CGFloat keyboardHeight;
    id <ItemDetailDelegate> m_delegate;
}

@property(nonatomic, retain) NSManagedObject *list;
@property(nonatomic, retain) NSManagedObject *item;
@property(nonatomic, retain) UITextView *textView;
@property(nonatomic, assign) id <ItemDetailDelegate> delegate;

@end

@protocol ItemDetailDelegate <NSObject>
- (void)itemDetailViewController:(ItemDetailViewController *)itemDetailViewController didSaveItem:(NSManagedObject *)item;
@end
