#import <UIKit/UIKit.h>


@interface ListDetailViewController : UITableViewController {
    UITableViewCell *_nameCell;
    IBOutlet id nameField;
}
@property (nonatomic, retain) IBOutlet UITableViewCell *nameCell;

-(IBAction)nameDidEnter:(UITextField *)textField;

@end
