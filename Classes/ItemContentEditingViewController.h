// ;-*-ObjC-*-
#import <UIKit/UIKit.h>
@protocol ItemContentEditingDelegate;

@interface ItemContentEditingViewController : UIViewController {
    NSManagedObject *m_item;
    NSManagedObject *m_list;
    BOOL keyboardShown;
    id <ItemContentEditingDelegate> m_delegate;
}
@property (nonatomic, retain) NSManagedObject *item;
@property (nonatomic, retain) NSManagedObject *list;
@property(nonatomic, assign) id <ItemContentEditingDelegate> delegate;
@end

@protocol ItemContentEditingDelegate <NSObject>
- (void)itemContentEditingViewController:(ItemContentEditingViewController *)controller didSaveItem:(NSManagedObject *)item;
@end
