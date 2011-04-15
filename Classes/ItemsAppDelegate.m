#import "ASIHTTPRequest.h"
#import "JSON.h"
#import <objc/runtime.h>

#import "ItemsAppDelegate.h"
#import "ListsViewController.h"
#import "Item.h"
#import "ResourceProtocol.h"
#import "HTTPResource.h"
#import "NSManagedObjectContextCategories.h"
#import "NSManagedObjectCategories.h"
#import "NSErrorCategories.h"
#import "NSDateCategories.h"
#import "NSUserDefaults+.h"
#import "Synchronizer.h"

//#define DUMP_SQLITE 1
#if DUMP_SQLITE
#include <sqlite3.h>
#endif
//#define API_CHANGES_URL

@interface ItemsAppDelegate (PrivateCoreDataStack)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@interface ItemsAppDelegate ()
- (void)sync;
@end

@implementation ItemsAppDelegate

@synthesize window = m_window;
@synthesize navigationController = m_navigationController;
@synthesize managedObjectContext = m_managedObjectContext;
@synthesize listsFetchedResultsController = m_listsFetchedResultsController;
@synthesize syncActivityIndicator = m_syncActivityIndicator;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSUserDefaults registerAppDefaults:@"AppDefaults"];
    //[NSUserDefaults resetToAppDefaults];
    //NSLog(@"defaults:%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    NSLog(@"launchOptions:%@", launchOptions);
    // handle url
    NSURL *url = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
    [self application:application handleOpenURL:url];
    
	[self.window addSubview:[self.navigationController view]];
	[self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_listsFetchedResultsController release];
    [m_managedObjectContext release];
    [m_managedObjectModel release];
    [m_persistentStoreCoordinator release];
    self.navigationController = nil;
    self.window = nil;
    self.syncActivityIndicator = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (url) {
        NSString *action = [url host];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        for (NSString *param in [[url query] componentsSeparatedByString:@"&"]) {
            NSArray *pair = [param componentsSeparatedByString:@"="];
            NSString *key = [pair objectAtIndex:0];
            NSString *value = [pair objectAtIndex:1];
            //NSLog(@"  %@ = %@", key, value);
            [params setObject:value forKey:key];
        }
        // invoke action
        if ([action compare:@"sync"] == NSOrderedSame) {
            NSString *key = [params objectForKey:@"key"];
            NSString *user_id = [params objectForKey:@"user_id"];
            [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"ApiKey"];
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"UserId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self sync];
        }
    }
    return YES;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges]) {
            // NOTE: don't save because inconsistent objects may cause validation errors.
            // (e.g. new item without cancel or save don't have NOT NULL attributes like created_at)
            //[managedObjectContext save];
            // TODO: not saved items should be saved as drafts
        }
    }
}

- (void)refreshUI {
    [[(ListsViewController *)[self.navigationController topViewController] tableView] reloadData];
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (m_managedObjectContext != nil) {
        return m_managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        m_managedObjectContext = [[NSManagedObjectContext alloc] init];
        [m_managedObjectContext setPersistentStoreCoordinator: coordinator];
        [m_managedObjectContext setRecordTimestamps:YES];
    }
    return m_managedObjectContext;
}

// - (void)resetManagedObjectContext {
//     [m_managedObjectModel release];
//     m_managedObjectModel = nil;
// }

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (m_managedObjectModel != nil) {
        return m_managedObjectModel;
    }
    m_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return m_managedObjectModel;
}

#if DUMP_SQLITE
int sqlite3_exec_callback(void* info,int numCols, char** texts, char** names) {
    int i;
    for (i = 0; i < numCols; i++) {
        if (texts[i])
            NSLog(@"%s: %@\n", names[i], [NSString stringWithUTF8String:texts[i]]);
    }
    return 0;
}
#endif

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (m_persistentStoreCoordinator != nil) {
        return m_persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"ItemsCoreData.sqlite"]];
#if DUMP_SQLITE
    sqlite3 *db = NULL;
    NSLog(@"db:%s\n", [[storeUrl path] UTF8String]);
    int dbrc = sqlite3_open([[storeUrl path] UTF8String], &db);
    if (dbrc) {
        NSLog(@"couldn't open db.");
        abort();
    }
    //int dbrc = sqlite3_prepare_v2(db, ".dump", -1, &dbps, NULL);
    //sqlite3_finalize(dbps);
//    if (SQLITE_ABORT == sqlite3_exec(db, "SELECT zcontent FROM zitem;", sqlite3_exec_callback, NULL, NULL)) {
    if (SQLITE_ABORT == sqlite3_exec(db, "UPDATE zitem SET zcontent = ' ' WHERE zcontent = '' OR zcontent IS NULL;", sqlite3_exec_callback, NULL, NULL)) {
        NSLog(@"couldn't exec.");
        abort();
    }
    sqlite3_close(db);
#endif
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                          [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    m_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![m_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        [error prettyPrint];
        abort();
    }    
    
    return m_persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Lists fetched result controller

- (NSFetchedResultsController *)listsFetchedResultsController {
    
    if (m_listsFetchedResultsController != nil) {
        return m_listsFetchedResultsController;
    }
    NSManagedObjectContext *context = self.managedObjectContext;
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // exclude deleted lists
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deleted_at == nil"];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    NSSortDescriptor *positionSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES] autorelease];
    NSSortDescriptor *createdSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:YES] autorelease];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:positionSortDescriptor, createdSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
//    DelegatingFetchedResultsController *aFetchedResultsController = [[DelegatingFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"List"];
    DelegatingFetchedResultsController *aFetchedResultsController = [[DelegatingFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];

    aFetchedResultsController.delegate = aFetchedResultsController; // delegating oneself
    m_listsFetchedResultsController = aFetchedResultsController;
    
    //[aFetchedResultsController release];
    [fetchRequest release];
    //[sortDescriptor release];
    [sortDescriptors release];
#if 1
    // fetch lists
    NSError *error = nil;
    if (![m_listsFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
#endif
    return m_listsFetchedResultsController;
}    

#pragma mark -
#pragma mark Application Helper

// Returns the path to the application's Documents directory.
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)sync {
    [Synchronizer sync];
}
@end

