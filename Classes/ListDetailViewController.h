#import <UIKit/UIKit.h>


@interface ListDetailViewController : UITableViewController {
    UITableViewCell *_nameCell;
}
@property (nonatomic, retain) IBOutlet UITableViewCell *nameCell;

-(IBAction)nameDidEnter:(UITextField *)textField;

@end
