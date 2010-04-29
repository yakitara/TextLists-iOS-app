//
//  ItemsCoreDataAppDelegate.h
//  ItemsCoreData
//
//  Created by hiroshi on 10/04/28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ItemsCoreDataAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (NSString *)applicationDocumentsDirectory;

@end

#define UIApp [UIApplication sharedApplication]
#define UIAppDelegate ((ItemsCoreDataAppDelegate*)UIApp.delegate)
