#import <UIKit/UIKit.h>


@interface ItemContentEditingViewController : UIViewController {
    NSManagedObject *_item;
    BOOL keyboardShown;
}
@property (nonatomic, retain) NSManagedObject *item;
@end
