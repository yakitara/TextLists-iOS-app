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

@interface NSManagedObject ( Timestamp )
- (BOOL)needUpdateTimestamp;
@end

@implementation NSManagedObject ( Timestamp )
- (BOOL)needUpdateTimestamp {
    NSSet *changedSet = [NSSet setWithArray:[[self changedValues] allKeys]];
    // if updated_at is modified, don't overwrite the value
    if ([changedSet member:@"updated_at"]) {
        return NO;
    }
    NSEntityDescription *entity = [self entity];
    NSSet *attributesSet = [NSSet setWithArray:[[entity attributesByName] allKeys]];
    // at least one attribute is changed
    if ([changedSet intersectsSet:attributesSet]) {
        return YES;
    }
    // or an aka belongs_to is changed
    for (NSRelationshipDescription *relationship in [[entity relationshipsByName] allValues]) {
        if (![relationship isToMany] && [changedSet containsObject:[relationship name]]) {
            return YES;
        }
    }
    return NO;
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
    for (NSManagedObject *managedObject in [self updatedObjects]) {
        if ([managedObject needUpdateTimestamp]) {
            [managedObject setTimestamps];
        }
    }
    for (NSManagedObject *managedObject in [self insertedObjects]) {
        if ([managedObject needUpdateTimestamp]) {
            [managedObject setTimestamps];
        }
    }
}
@end

