#import "NSManagedObjectContextCategories.h"

// @interface NSManagedObjectContext ()
// - (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest;
// @end

@implementation NSManagedObjectContext ( Convenience )
- (void)save {
    NSError *error = nil;
    if (![self save:&error]) {
        /*
            Replace this implementation with code to handle the error appropriately.
            
            abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
        */
        [error prettyPrint];
        abort();
    }
}

- (NSArray *)fetchFromEntityName:(NSString *)entityName withPredicateFormat:(NSString *)predicateFormat argumentArray:(NSArray *)arguments
{
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
    [fetchRequest setPredicate:predicate];
    return [self executeFetchRequest:fetchRequest];
}

- (NSManagedObject *)fetchFirstFromEntityName:(NSString *)entityName withPredicateFormat:(NSString *)predicateFormat argumentArray:(NSArray *)arguments {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    return [[self executeFetchRequest:fetchRequest] lastObject];
}

/*
- (NSManagedObject *)fetchFirstFromEntityName:(NSString *)entityName withPredicateFormat:(NSString *)predicateFormat argumentArray:(NSArray *)arguments {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    return [[self executeFetchRequest:fetchRequest] lastObject];
}
*/
- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest {
    NSError *error = nil;
    NSArray *records = [self executeFetchRequest:fetchRequest error:&error];
    if (!records) {
        [error prettyPrint];
        abort();
    }
    return records;
}
@end

// automatically set timestamps like ActiveRecord::Timestamp
@implementation NSManagedObjectContext ( Timestamp )
- (void)setRecordTimestamps:(BOOL)recordTimestamp {
    if (recordTimestamp) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willSaveNotification:) name:NSManagedObjectContextWillSaveNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:self];
    }
}
// TODO: it must be better to implement delegate class for the observer object
- (void)willSaveNotification:(NSNotification *)aNotification {
    NSDate *now = [NSDate date];
    for (NSManagedObject *managedObject in [self updatedObjects]) {
        if ([managedObject needUpdate]) {
            [managedObject setTimestamps:now];
            [managedObject insertChangeLog];
        }
    }
    for (NSManagedObject *managedObject in [self insertedObjects]) {
        if ([managedObject needUpdate]) {
            [managedObject setTimestamps:now];
            [managedObject insertChangeLog];
        }
    }
}
@end

