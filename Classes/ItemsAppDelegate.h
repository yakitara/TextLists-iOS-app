#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ItemsAppDelegate : NSObject <UIApplicationDelegate> {
    
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
#define UIAppDelegate ((ItemsAppDelegate*)UIApp.delegate)
