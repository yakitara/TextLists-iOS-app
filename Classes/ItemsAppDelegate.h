#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DelegatingFetchedResultsController.h"

@interface ItemsAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *m_managedObjectModel;
    NSManagedObjectContext *m_managedObjectContext;
    NSPersistentStoreCoordinator *m_persistentStoreCoordinator;

    UIWindow *m_window;
    UINavigationController *m_navigationController;
    
    DelegatingFetchedResultsController *m_listsFetchedResultsController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) DelegatingFetchedResultsController *listsFetchedResultsController;

- (NSString *)applicationDocumentsDirectory;

@end

#define UIApp [UIApplication sharedApplication]
#define UIAppDelegate ((ItemsAppDelegate*)UIApp.delegate)
