#import "ASIHTTPRequest.h"
#import "JSON.h"

#import "Synchronizer.h"
#import "ChangeLog.h"
#import "ItemsAppDelegate.h"
#import "NSManagedObjectContextCategories.h"
#import "NSManagedObjectCategories.h"
#import "EntityNameProtocol.h"

@interface Synchronizer ()
- (void)sync;
- (void)postChangeLog:(NSManagedObject *)record;
- (void)postChangeLogs:(NSArray *)records;
- (void)postJSONRepresentationOf:(id)value toPath:(NSString *)path auth:(BOOL)auth userInfo:(id)userInfo;
+ (NSURL *)requestURLForPath:(NSString *)path auth:(BOOL)auth;
- (void)getChangeLog;
- (void)stop;
@end

@implementation Synchronizer
@synthesize postQueue=m_postQueue;

+ (Synchronizer *)singletonSynchronizer {
    static Synchronizer *s_singleton = NULL;
    if (!s_singleton) {
        s_singleton = [[self alloc] init];
    }
    return s_singleton;
}

+ (void)sync {
    // Quick and dirty way of preventing multiple sync
    if ([UIAppDelegate.syncActivityIndicator isAnimating]) {
        return;
    }
    
    // if (s_singleton) {
    //     [s_singleton stop];
    // } else {
    //     s_singleton = [[self alloc] init];
    // }
    [[self singletonSynchronizer] stop];
    [UIAppDelegate.syncActivityIndicator startAnimating];
    [[self singletonSynchronizer] sync];
}

- (void)stop {
    self.postQueue = nil;
    [UIAppDelegate.syncActivityIndicator stopAnimating];
    [UIAppDelegate refreshUI];
}

- (void)dealloc {
    [m_postQueue release];
    [super dealloc];
}

- (void)sync {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"ApiKey"]) {
        [UIApp openURL:[[self class] requestURLForPath:@"/api/key?r=items://sync/" auth:NO]];
        [self stop];
        return;
    }
    
    if ([self.postQueue count] > 0) {
        if ([defaults boolForKey:@"PostBulkChanges"]) {
            NSRange range = NSMakeRange(0, MIN([self.postQueue count], [defaults integerForKey:@"PostBulkChangesLimit"]));
            [self postChangeLogs:[self.postQueue subarrayWithRange:range]];
        } else {
            [self postChangeLog:[self.postQueue objectAtIndex:0]];
        }
    } else {
        [self getChangeLog];
        //[self stop];
    }
}

// POST many changes at a request
- (void)postChangeLogs:(NSArray *)records {
    NSMutableArray *logs = [NSMutableArray arrayWithCapacity:[records count]];
    for (NSManagedObject <EntityName> *record in records) {
        [logs addObject:[ChangeLog changeForManagedObject:record]];
    }
    NSDictionary *value = [NSDictionary dictionaryWithObject:logs forKey:@"changes"];
    NSDictionary *info = [NSDictionary dictionaryWithObject:records forKey:@"records"];
    [self postJSONRepresentationOf:value toPath:@"/api/changes" auth:YES userInfo:info];
}

// POST a change at a request
- (void)postChangeLog:(NSManagedObject <EntityName> *)record {
    id log = [ChangeLog changeForManagedObject:record];
    NSDictionary *info = [NSDictionary dictionaryWithObject:record forKey:@"record"];
    [self postJSONRepresentationOf:log toPath:@"/api/changes" auth:YES userInfo:info];
}

- (void)postJSONRepresentationOf:(id)value toPath:(NSString *)path auth:(BOOL)auth userInfo:(id)userInfo {
    NSURL *url = [[self class] requestURLForPath:path auth:auth];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[value JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    request.requestMethod = @"POST";
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    request.delegate = self;
    request.didFinishSelector = @selector(postChangeLogRequestFinished:);
    request.userInfo = userInfo;
    [request startAsynchronous];
}

- (void)postChangeLogRequestFinished:(ASIHTTPRequest *)request {
    if (request.responseStatusCode / 100 == 5) {
        // TODO: alert the user with error
        [self stop];
    } else if (request.responseStatusCode == 403) {
        // Authentication failed. Retry from login phase
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ApiKey"];
        [self sync];
    } else if(request.responseStatusCode / 100 == 2) {
        NSArray *records = [request.userInfo objectForKey:@"records"];
        if (!records) {
            records = [NSArray arrayWithObject:[request.userInfo objectForKey:@"record"]];
        }
        id responseValue = [request.responseString JSONValue];
        if (![responseValue respondsToSelector:@selector(objectAtIndex:)]) {
            responseValue = [NSArray arrayWithObject:responseValue];
        }
        //for (NSManagedObject *record in records) {
        for (int i = 0; i < [records count]; i++) {
            NSManagedObject *record = [records objectAtIndex:i];
            NSDictionary *dict = [responseValue objectAtIndex:i];
            if ([record isKindOfClass:[ChangeLog class]]) {
                // delete the change log
                [[record managedObjectContext] deleteObject:record];
                [[record managedObjectContext] save];
            } else {
                // set id for new record
                [record setValue:[dict valueForKey:@"id"] forKey:@"id"]; // the name of key should be record_id instead
                [record setValue:[NSDate date] forKey:@"synched_at"];
                [[record managedObjectContext] save];
            }
            // remove the object from the queue
            [self.postQueue removeObject:record];
        }
        // what's next?
        [self sync];
    }
}

- (NSMutableArray *)postQueue {
    if (!m_postQueue) {
        m_postQueue = [[NSMutableArray alloc] init];
        NSManagedObjectContext *context = [UIAppDelegate managedObjectContext];
        // records which id is not determind yet
        for (NSString *entityName in [NSArray arrayWithObjects:@"List", @"Item", @"Listing", nil]) {
            NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == nil"];
            [fetchRequest setPredicate:predicate];
            NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:YES] autorelease];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [m_postQueue addObjectsFromArray:[context executeFetchRequest:fetchRequest]];
        }
#if 1
        // It is possible that a new record has not uuid if created before update of the app
        // NOTE: This code will be perged in some future
        for (NSManagedObject *newRecord in m_postQueue) {
            [newRecord setUUID];
        }
        [context save];
#endif
        // changelogs
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChangeLog" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:YES] autorelease];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [m_postQueue addObjectsFromArray:[context executeFetchRequest:fetchRequest]];
    }
    return m_postQueue;
}

- (void)getChangeLog {
    NSInteger lastLogId = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastLogId"];
    
    NSString *path = [NSString stringWithFormat:@"/api/changes/next/%d", lastLogId];
    NSURL *url = [[self class] requestURLForPath:path auth:YES];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    request.delegate = self;
    request.didFinishSelector = @selector(getChangeLogRequestFinished:);
    [request startAsynchronous];
}

- (void)getChangeLogRequestFinished:(ASIHTTPRequest *)request {
    if (request.responseStatusCode / 100 == 5) {
        // TODO: alert the user with error
        [self stop];
    } else if (request.responseStatusCode == 403) {
        // Authentication failed. Retry from login phase
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ApiKey"];
        [self sync];
    } else if (request.responseStatusCode == 204) { // '204 No Content' means no more log newer than given log id
        [self stop];
    } else if(request.responseStatusCode == 200) {
        NSDictionary *log = [request.responseString JSONValue];
        //
        NSManagedObjectContext *context = [UIAppDelegate managedObjectContext];
        NSString *entityName = [log objectForKey:@"record_type"];
        NSNumber *record_id = [log objectForKey:@"record_id"];
        NSManagedObject *record = [context fetchFirstFromEntityName:entityName withPredicateFormat:@"id == %@" argumentArray:[NSArray arrayWithObjects:record_id, nil]];
        if (!record) {
            record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        }
        [record setValues:[[log objectForKey:@"json"] JSONValue]];
        // TODO: consider atomicity of save and updating lastLogId, storing lastLogId in ManagedObject will be safe
        [context save];
        
        //[context processPendingChanges];
        
        // update LastLogId
        NSNumber *lastLogId = [log objectForKey:@"id"];
        [[NSUserDefaults standardUserDefaults] setInteger:[lastLogId integerValue] forKey:@"LastLogId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // FIXME: Don't do such a entity specific thing here.
        // FIXME: using NSFetchedResultController in ItemsViewController will solve the refreshing issue
        if ([entityName isEqual:@"Listing"]) {
            [context refreshObject:[record valueForKey:@"list"] mergeChanges:NO];
        }
//        [context refreshObject:[record valueForKey:@"list"] mergeChanges:NO];
        
//        [UIAppDelegate resetManagedObjectContext];
        
        // what's next?
        [self sync];
    }
}

+ (NSURL *)requestURLForPath:(NSString *)path auth:(BOOL)auth {
    // FIXME: use preferences or...
// #if TARGET_IPHONE_SIMULATOR
//     NSString *baseURLString = [NSString stringWithFormat:@"http://local.items.yakitara.com:3000%@", path];
// #else
//     NSString *baseURLString = [NSString stringWithFormat:@"http://textlists.yakitara.com%@", path];
// #endif
    NSURL *rootURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"WebServiceURL"]];
    NSURL *url = [NSURL URLWithString:path relativeToURL:rootURL];
    if (auth) {
        NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:@"ApiKey"];
        NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"];
        if (key) {
            //return [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%@&key=%@", baseURLString, user_id, key]];
            url = [NSURL URLWithString:[NSString stringWithFormat:@"?user_id=%@&key=%@", user_id, key] relativeToURL:url];
        } else {
            url = nil;
        }
    }
    // NOTE: I don' know why, but an URL created by URLWithString:relativeToURL: cannot be opend with -[UIApplication openURL]
    return [NSURL URLWithString:[url absoluteString]];
}

@end
