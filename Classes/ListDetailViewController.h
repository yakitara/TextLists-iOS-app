//
//  ListDetailViewController.h
//  ItemsCoreData
//
//  Created by hiroshi on 10/04/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListDetailViewController : UITableViewController {
    UITableViewCell *_nameCell;
}
@property (nonatomic, retain) IBOutlet UITableViewCell *nameCell;

-(IBAction)nameDidEnter:(UITextField *)textField;

@end
