// ;-*-ObjC-*-
#import <UIKit/UIKit.h>
@protocol ItemContentEditingDelegate;

@interface ItemContentEditingViewController : UIViewController {
    NSManagedObject *m_item;
    NSManagedObject *m_list;
    id <ItemContentEditingDelegate> m_delegate;
    UISegmentedControl *m_segmented;    
    BOOL keyboardShown;
}
@property (nonatomic, retain) NSManagedObject *item;
@property (nonatomic, retain) NSManagedObject *list;
@property (nonatomic, assign) id <ItemContentEditingDelegate> delegate;
@property (nonatomic, assign) UISegmentedControl *segmented;
@end

@protocol ItemContentEditingDelegate <NSObject>
- (void)itemContentEditingViewController:(ItemContentEditingViewController *)controller didSaveItem:(NSManagedObject *)item;
@end
