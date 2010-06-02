// ;-*-ObjC-*-
#import <UIKit/UIKit.h>
#import "ListsViewController.h"
@protocol ItemContentEditingDelegate;

@interface ItemContentEditingViewController : UIViewController < ListsViewControllerDelegate > {
    NSManagedObject *m_item;
    NSManagedObject *m_list;
    id <ItemContentEditingDelegate> m_delegate;
//    UISegmentedControl *m_segmented;    
    BOOL keyboardShown;
    IBOutlet id m_textView;
    IBOutlet id m_listButton;
}
@property (nonatomic, retain) NSManagedObject *item;
@property (nonatomic, retain) NSManagedObject *list;
@property (nonatomic, assign) id <ItemContentEditingDelegate> delegate;
//@property (nonatomic, retain) UISegmentedControl *segmented;
- (IBAction)changeList:(id)sender;
@end

@protocol ItemContentEditingDelegate <NSObject>
- (void)itemContentEditingViewController:(ItemContentEditingViewController *)controller didSaveItem:(NSManagedObject *)item;
@end
