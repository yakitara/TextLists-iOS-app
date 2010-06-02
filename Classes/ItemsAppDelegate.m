#import "ASIHTTPRequest.h"
#import "JSON.h"

#import "ItemsAppDelegate.h"
#import "ListsViewController.h"
#import "Item.h"
#import "ResourceProtocol.h"
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

@synthesize window;
@synthesize navigationController;
@synthesize managedObjectContext;
@synthesize listsFetchedResultsController=m_listsFetchedResultsController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    NSLog(@"launchOptions:%@", launchOptions);
    // parse url
    NSURL *url = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
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
    
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
    return YES;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            //[self saveWithManagedObjectContext:managedObjectContext];
            [managedObjectContext save];
        }
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
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
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
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
    if (SQLITE_ABORT == sqlite3_exec(db, "SELECT zcontent FROM zitem;", sqlite3_exec_callback, NULL, NULL)) {
        NSLog(@"couldn't exec.");
        abort();
    }
    sqlite3_close(db);
#endif
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                          [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
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
    DelegatingFetchedResultsController *aFetchedResultsController = [[DelegatingFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"List"];
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

#pragma mark -
#pragma mark Sync

//TODO: A path may contain paramaters. consider to sepalate it from the path.
- (NSURL *)requestURLForPath:(NSString *)path auth:(BOOL)auth {
    if (auth) {
        NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:@"ApiKey"];
        NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        if (key) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000%@?user_id=%@&key=%@", path, user_id, key]];
        } else {
            return nil;
        }
    } else {
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000%@", path]];
    }
}

- (void)sync {
//     NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:@"ApiKey"];
//     NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
    NSURL *url = [self requestURLForPath:@"/api/changes" auth:YES];
    if (url) {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [request startAsynchronous];
    } else {
        // get api key through web
        //[UIApp openURL:[NSURL URLWithString:@"http://localhost:3000/api/key?r=items://sync/"]];
        [UIApp openURL:[self requestURLForPath:@"/api/key?r=items://sync/" auth:NO]];
    }
}

- (void)mergeChanges:(NSArray *)changes forEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context {
    for (NSDictionary *dict in changes) {
        NSNumber *record_id = [dict objectForKey:@"id"];
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", record_id];
        [fetchRequest setPredicate:predicate];
        NSArray *records = [context executeFetchRequest:fetchRequest];
/*
        NSError *error;
        NSArray *records = [context executeFetchRequest:fetchRequest error:&error];
        if (!records) {
            NSLog(@"Fetching %@ failed:%@, $@", entityName, error, [error userInfo]);
            abort();
        }
*/
        NSManagedObject *record = [records lastObject];
        if (record) {
            NSDate *localDate = [record valueForKey:@"updated_at"];
            NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
            NSDate *remoteDate = [dateFormatter dateFromString:[dict objectForKey:@"updated_at"]];
            if ([remoteDate compare:localDate] > 0) {
                //  web -> app: UPDATE
                for (id key in dict) {
                    [record setValue:[dict objectForKey:key] forKey:key];
                }
            } else {
                // web <- app: keep record to be uploaded
                //FIXME: [uploadingItems addObject:item];
            }
        } else {
            // web -> app: INSERT
            record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
            NSLog(@"new Record:%@", record);
            for (NSString *key in dict) {
                [record setValue:[dict objectForKey:key] forKey:key];
            }
        }
    }
}

- (void)uploadChangesOfEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == nil"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"updated_at" ascending:YES] autorelease];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
    [fetchRequest setSortDescriptors:sortDescriptors];
    for (NSManagedObject <ResourceSupport> *record in [context executeFetchRequest:fetchRequest]) {
        NSString *json = [[NSDictionary dictionaryWithObjectsAndKeys:record, [entityName lowercaseString], nil] JSONRepresentation];
        NSLog(@"uploading JSON:%@", json);
//        NSURL *url = [self requestURLForPath:@"/api/items" auth:YES];
        NSURL *url = [self requestURLForPath:[[record class] resourcePath] auth:YES];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
        // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
        request.requestMethod = @"POST";
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        //request.didFinishSelector = @selector(postFinished:);
        // FIXME: do it async
        [request startSynchronous];
        NSError *error = [request error];
        if (error) {
            [error prettyPrint];
            abort();
        }
        NSString *responseJSON = [request responseString];
        NSLog(@"responseJSON: %@", responseJSON);
        NSDictionary *responseDict = [responseJSON JSONValue];
        [record setValue:[responseDict valueForKey:@"id"] forKey:@"id"];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    // Use when fetching text data
    NSString *responseString = [request responseString];
    int status = request.responseStatusCode;
    if (status == 200) {
        NSLog(@"sync response: %@", responseString);
        NSDictionary *changes = [responseString JSONValue];
        NSLog(@"  changes:%@", changes);
        NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
        //NSMutableArray *uploadingItems = [NSMutableArray array];
#if 0
        // Download from web
        [self mergeChanges:[changes objectForKey:@"items"] forEntityName:@"Item" inContext:context];
        [self mergeChanges:[changes objectForKey:@"lists"] forEntityName:@"List" inContext:context];
        [self mergeChanges:[changes objectForKey:@"listings"] forEntityName:@"Listing" inContext:context];
        //[self saveWithManagedObjectContext:context];
        [context save];
#endif
        // Upload to web
        //NSString *itemsJson = [[NSDictionary dictionaryWithObjectsAndKeys:uploadingItems, @"items", nil] JSONRepresentation];
        [self uploadChangesOfEntityName:@"List" inContext:context];
        [self uploadChangesOfEntityName:@"Item" inContext:context];
        [self uploadChangesOfEntityName:@"Listing" inContext:context];
/*
        // upload
        NSString *json = [[NSDictionary dictionaryWithObjectsAndKeys:
                                            uploadingItems, @"items",
                                        nil] JSONRepresentation];
*/
//        NSLog(@"TODO: uploading json:\n%@", json);
#if 0
        NSString *updated_at = [[[changes objectForKey:@"items"] lastObject] objectForKey:@"updated_at"];
        NSDateFormatter *dateFormatter = [NSDateFormatter 
            [dateFormatter  (NSDate *)dateFromString:(NSString *)string

           
#endif   
    } else if (status == 403) {
        // key is not correct. Retry from login
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ApiKey"];
        [self sync];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync failed" message:request.responseStatusMessage
                                                  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];    
    }
}
 
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"sync error: %@", error);
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [m_listsFetchedResultsController release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [navigationController release];
    [window release];
    [super dealloc];
}



@end

