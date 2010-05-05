//
//  ItemContentEditingViewController.h
//  ItemsCoreData
//
//  Created by hiroshi on 10/05/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ItemContentEditingViewController : UIViewController {
    NSManagedObject *_item;
    BOOL keyboardShown;
}
@property (nonatomic, retain) NSManagedObject *item;
@end
