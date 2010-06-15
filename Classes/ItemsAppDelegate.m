#import "ASIHTTPRequest.h"
#import "JSON.h"

#import "ItemsAppDelegate.h"
#import "ListsViewController.h"
#import "Item.h"
#import "ResourceProtocol.h"
#import "HTTPResource.h"
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
    
	[self.window addSubview:[self.navigationController view]];
	[self.window makeKeyAndVisible];
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

#pragma mark -
#pragma mark Sync

//TODO: A path may contain paramaters. consider to sepalate it from the path.
- (NSURL *)requestURLForPath:(NSString *)path auth:(BOOL)auth {
    // FIXME: use preferences or...
#if __arm__
    NSString *baseURLString = [NSString stringWithFormat:@"http://items.yakitara.com:8000%@", path];
#else
    NSString *baseURLString = [NSString stringWithFormat:@"http://localhost:3000%@", path];
#endif
    if (auth) {
        NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:@"ApiKey"];
        NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        if (key) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%@&key=%@", baseURLString, user_id, key]];
        } else {
            return nil;
        }
    } else {
        return [NSURL URLWithString:baseURLString];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    id <NSObject, NSManagedObjectClassFetch, ResourceSupport> managedObjectClass = objc_getClass([[entity managedObjectClassName] UTF8String]);
    
    for (NSDictionary *dict in changes) {
        NSNumber *record_id = [dict objectForKey:@"id"];
        NSArray *records = [context fetchFromEntityName:entityName withPredicateFormat:@"id == %@" argumentArray:[NSArray arrayWithObject:record_id]];
        NSManagedObject *record = [records lastObject];
        if (record) {
            NSDate *localDate = [record valueForKey:@"updated_at"];
            //NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
            //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
            //NSDate *remoteDate = [dateFormatter dateFromString:[dict objectForKey:@"updated_at"]];
            NSDate *remoteDate = [NSDate dateFromJSONDateString:[dict objectForKey:@"updated_at"]];
            //NSComparisonResult compResult = [remoteDate compare:localDate];
            // NOTE: ignoring differences less than a second
            NSTimeInterval diffInSeconds = [remoteDate timeIntervalSinceDate:localDate];
            if (diffInSeconds >= 1.0) {
                //  web -> app: UPDATE
#if 1
                // changes only have id and updated_at, so get whole of the resource
                NSString *path = [NSString stringWithFormat:@"%@/%@", [managedObjectClass resourcePath], record_id];
                NSURL *url = [self requestURLForPath:path auth:YES];
                //NSDictionary *values = [WebResource getJSONValueFrom:url];
                NSDictionary *values = [HTTPResource getJSONValueFromURL:url];
                for (id key in values) {
                    [record setValue:[values objectForKey:key] forKey:key];
                }
#else
                for (id key in dict) {
                    [record setValue:[dict objectForKey:key] forKey:key];
                }
#endif
            } else if (diffInSeconds <= -1.0) {
                // web <- app: keep record to be uploaded
                NSDictionary *value = [NSDictionary dictionaryWithObjectsAndKeys:record, [entityName lowercaseString], nil];
                NSString *path = [NSString stringWithFormat:@"%@/%@", [managedObjectClass resourcePath], record_id];
                NSURL *url = [self requestURLForPath:path auth:YES];
                [HTTPResource putJSONValue:value onURL:url];
                //TODO: error check
                //id *record_id = [[responseDict valueForKey:@"id"] forKey:@"id"];
                //TODO: should use response code of the request
//                 if (record_id != [NSNull null]) {
//                     [record setValue:record_id];
//                     [context save]; // one request, one transaction
//                 }
            }
        } else {
            // If there is an object with identical properties, use the object instead of new one.
            NSString *path = [NSString stringWithFormat:@"%@/%@", [managedObjectClass resourcePath], record_id];
            NSURL *url = [self requestURLForPath:path auth:YES];
            NSDictionary *values = [HTTPResource getJSONValueFromURL:url];

            if ([managedObjectClass respondsToSelector:@selector(fetchObjectIdenticalToValues:inManagedObjectContext:)]) {
                record = [managedObjectClass fetchObjectIdenticalToValues:values inManagedObjectContext:context];
            }
            if (!record) {
                // web -> app: INSERT
                record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
            }
            //NSLog(@"merged record:%@", record);
            for (id key in values) {
                [record setValue:[values objectForKey:key] forKey:key];
            }
        }
        [context save];
    }
}

- (void)uploadChangesOfEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    id <NSObject, NSManagedObjectClassFetch, ResourceSupport> managedObjectClass = objc_getClass([[entity managedObjectClassName] UTF8String]);
    
#if 0
    // TODO: implement convenient fetch method including sort
    NSArray *records = [context fetchFromEntityName:entityName withPredicateFormat:@"id == nil" argumentArray:[NSArray array] sortKeysAndAscendings];
    for (NSManagedObject <ResourceSupport> *record in records) {
#else
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == nil"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"updated_at" ascending:YES] autorelease];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
    [fetchRequest setSortDescriptors:sortDescriptors];
    for (NSManagedObject <ResourceSupport> *record in [context executeFetchRequest:fetchRequest]) {
#endif

#if 1
        NSDictionary *value = [NSDictionary dictionaryWithObjectsAndKeys:record, [entityName lowercaseString], nil];
        NSURL *url = [self requestURLForPath:[managedObjectClass resourcePath] auth:YES];
        NSDictionary *responseDict = [HTTPResource postJSONValue:value toURL:url];
        id record_id = [responseDict valueForKey:@"id"];
        //TODO: should use response code of the request
        if (record_id != [NSNull null]) {
            [record setValue:record_id forKey:@"id"];
            [context save]; // one request, one transaction
        }
#else
        NSString *json = [[NSDictionary dictionaryWithObjectsAndKeys:record, [entityName lowercaseString], nil] JSONRepresentation];
        NSLog(@"uploading JSON:%@", json);
//        NSURL *url = [self requestURLForPath:@"/api/items" auth:YES];
        NSURL *url = [self requestURLForPath:[managedObjectClass resourcePath] auth:YES];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
        // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
        request.requestMethod = @"POST";
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        //request.didFinishSelector = @selector(postFinished:);
        // TODO: do it async? or 
        [request startSynchronous];
        NSError *error = [request error];
        if (!error) {
            NSString *responseJSON = [request responseString];
            NSLog(@"responseJSON: %@", responseJSON);
            if (request.responseStatusCode == 200) {
                NSDictionary *responseDict = [responseJSON JSONValue];
                [record setValue:[responseDict valueForKey:@"id"] forKey:@"id"];
                // one request, one transaction
                [context save];
            }
        } else {
            [error prettyPrint];
            abort(); // TODO: store error info and skip
        }
#endif
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    // Use when fetching text data
    NSString *responseString = [request responseString];
    int status = request.responseStatusCode;
    if (status == 200) {
        //NSLog(@"sync response: %@", responseString);
        NSDictionary *changes = [responseString JSONValue];
        //NSLog(@"  changes:%@", changes);
        NSManagedObjectContext *context = self.managedObjectContext;
        //NSMutableArray *uploadingItems = [NSMutableArray array];
        // disable auto timestamp
        // TODO: it is needed to use another context than default one when sync is executed on a worker thread
        //[m_managedObjectContext setRecordTimestamps:NO];
        // Download from web
        [self mergeChanges:[changes objectForKey:@"items"] forEntityName:@"Item" inContext:context];
        [self mergeChanges:[changes objectForKey:@"lists"] forEntityName:@"List" inContext:context];
        [self mergeChanges:[changes objectForKey:@"listings"] forEntityName:@"Listing" inContext:context];
        // Upload to web
        //NSString *itemsJson = [[NSDictionary dictionaryWithObjectsAndKeys:uploadingItems, @"items", nil] JSONRepresentation];
        [self uploadChangesOfEntityName:@"List" inContext:context];
        [self uploadChangesOfEntityName:@"Item" inContext:context];
        [self uploadChangesOfEntityName:@"Listing" inContext:context];
        //[m_managedObjectContext setRecordTimestamps:NO];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_listsFetchedResultsController release];
    [m_managedObjectContext release];
    [m_managedObjectModel release];
    [m_persistentStoreCoordinator release];
    self.navigationController = nil;
    self.window = nil;
    [super dealloc];
}



@end

