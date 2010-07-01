#import "ASIHTTPRequest.h"
#import "JSON.h"

#import "Synchronizer.h"
#import "ChangeLog.h"
#import "ItemsAppDelegate.h"

static Synchronizer *s_singleton = NULL;

@interface Synchronizer ()
- (void)postChangeLog:(NSManagedObject *)record;
+ (NSURL *)requestURLForPath:(NSString *)path auth:(BOOL)auth;
- (void)stop;
@end

@implementation Synchronizer
@synthesize postQueue=m_postQueue;
+ (void)sync {
    if (s_singleton) {
        [s_singleton stop];
    } else {
        s_singleton = [[self alloc] init];
    }
    [UIAppDelegate.syncActivityIndicator startAnimating];
    [s_singleton sync];
}

- (void)stop {
    self.postQueue = nil;
    [UIAppDelegate.syncActivityIndicator stopAnimating];
}

- (void)dealloc {
    [m_postQueue release];
    [super dealloc];
}

- (void)sync {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ApiKey"]) {
        [UIApp openURL:[[self class] requestURLForPath:@"/api/key?r=items://sync/" auth:NO]];
        [self stop];
        return;
    }
    
    if ([self.postQueue count] > 0) {
        [self postChangeLog:[self.postQueue objectAtIndex:0]];
    } else {
        //[self getChangeLog];
        [self stop];
    }
}

- (void)postChangeLog:(NSManagedObject <EntityName> *)record {
    id log = nil;
    if ([record isKindOfClass:[ChangeLog class]]) {
        log = record;
    } else {
        log = [NSMutableDictionary dictionary];
        [log setObject:[[record class] entityName] forKey:@"record_type"];
        [log setObject:[record JSONRepresentation] forKey:@"json"];
        [log setObject:[NSDate date] forKey:@"created_at"];
    }
    NSURL *url = [[self class] requestURLForPath:@"/api/changes" auth:YES];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[log JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    request.requestMethod = @"POST";
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    request.delegate = self;
    request.didFinishSelector = @selector(postChangeLogRequestFinished:);
    request.userInfo = [NSDictionary dictionaryWithObject:record forKey:@"record"];
    [request startAsynchronous];
}

- (void)postChangeLogRequestFinished:(ASIHTTPRequest *)request {
    if (request.responseStatusCode / 100 == 5) {
        [self stop];
        return;
    } else if (request.responseStatusCode == 403) {
        // Authentication failed. Retry from login phase
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ApiKey"];
    } else if(request.responseStatusCode / 100 == 2) {
        NSManagedObject *record = [request.userInfo objectForKey:@"record"];
        NSDictionary *responseValue = [request.responseString JSONValue];
        if ([record isKindOfClass:[ChangeLog class]]) {
            // delete the change log
            [[record managedObjectContext] deleteObject:record];
        } else {
            // set id for new record
            [record setValue:[responseValue valueForKey:@"id"] forKey:@"id"];
            [record setValue:[NSDate date] forKey:@"synched_at"];
            [[record managedObjectContext] save];
        }
        // remove the object from the queue
        [self.postQueue removeObject:record];
    }
    // what's next?
    [self sync];
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

+ (NSURL *)requestURLForPath:(NSString *)path auth:(BOOL)auth {
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

@end
