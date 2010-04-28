//
//  RootViewController.h
//  ItemsCoreData
//
//  Created by hiroshi on 10/04/28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *_managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
