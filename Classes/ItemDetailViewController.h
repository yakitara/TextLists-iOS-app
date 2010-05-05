#import <UIKit/UIKit.h>


@interface ItemDetailViewController : UITableViewController {
//    UITableViewCell *_contentCell;
//    UITextView *_textView;
    NSManagedObject *_list;
    NSManagedObject *_item;
    
//    UITextView *_contentView;
//    UITableViewCell *_contentCell;
    UILabel *_contentLabel;
    
}
//@property (readonly, nonatomic) IBOutlet UITableViewCell *contentCell;
//@property (readonly, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSManagedObject *list;
@property (nonatomic, retain) NSManagedObject *item;
@property (nonatomic, retain) UILabel *contentLabel;
//@property (nonatomic, retain) UITextView *contentView;

//-(IBAction)contentDidEnter:(UITextView *)textView;
//-(IBAction)contentDidEnter:(id)sender;

@end
