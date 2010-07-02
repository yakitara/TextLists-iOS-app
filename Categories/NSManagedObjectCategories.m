#import "JSON.h"

#import "NSManagedObjectCategories.h"
#import "NSManagedObjectContextCategories.h"
#import "ChangeLog.h"
#import "NSDateCategories.h"
#import "ChangeLogProtocol.h"
#import "EntityNameProtocol.h"

@implementation NSManagedObject ( TimeStamps )
- (void)setUpdated_at:(id)value {
    [self setDate:value forKey:@"updated_at"];
}

- (void)setCreated_at:(id)value {
    [self setDate:value forKey:@"created_at"];
}

- (void)setDeleted_at:(id)value {
    [self setDate:value forKey:@"deleted_at"];
}

- (void)setDate:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSString class]]) {
//         BOOL isUTC = ([value rangeOfString:@"Z" options:NSBackwardsSearch].location != NSNotFound);
//         value = [[NSDate JSONDateFormatter:isUTC] dateFromString:value];
        value = [NSDate dateFromJSONDateString:value];
    } else if ([value isKindOfClass:[NSNull class]]) {
        value = nil;
    }
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:value forKey:key];
    [self didChangeValueForKey:key];
}

- (void)setTimestamps:(NSDate *)date {
    if (!date) {
        date = [NSDate date];
    }
    if (![self valueForKey:@"created_at"]) {
        [self setValue:date forKey:@"created_at"];
    }
    [self setValue:date forKey:@"updated_at"];
}
@end

@implementation NSManagedObject ( Association )
- (void)setBelongsToId:(id)value forKey:(NSString *)key entityName:(NSString *)entityName {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", value];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *records = [context executeFetchRequest:fetchRequest error:&error];
    if (!records) {
        NSLog(@"Fetching %@ failed:%@, $@", entityName, error, [error userInfo]);
        abort();
    }
    // set CoreData relation
    [self setValue:[records lastObject] forKey:key];
}

@end

@implementation NSManagedObject ( JSON )
- (id)proxyForJson {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *attr in [[[self entity] attributesByName] allKeys]) {
        [dict setValue:[self valueForKey:attr] forKey:attr];
    }
    for (NSRelationshipDescription *relationship in [[[self entity] relationshipsByName] allValues]) {
        // because of toMany relationships don't have foreign key, but the other side does
        if (![relationship isToMany]) {
            NSString *name = [relationship name];
            NSString *key = [name stringByAppendingString:@"_id"];
            NSString *value = [[self valueForKey:name] valueForKey:@"id"];
            [dict setValue:value forKey:key];
        }
    }
    NSLog(@"proxyForJson:%@", dict);
    return dict;
}
@end

@implementation NSManagedObject ( Identity )
- (BOOL)isIdentical:(NSManagedObject*)anManagedObject {
    return [[self objectID] isEqual:[anManagedObject objectID]];
}
@end

@implementation NSManagedObject ( UndefinedKey )
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%@: Ignoring setValue:%@ forUndefinedKey:%@", self, value, key);
}
@end

@implementation NSManagedObject ( Change )
- (BOOL)insertChangeLog {
    if (![self respondsToSelector:@selector(needChangeLog)] || ![(id< ChangeLog >)self needChangeLog]) {
        return NO;
    }
    NSMutableDictionary *change = [self selfChangedValues];
    if (change) {
        // return NO even if id of self or of to-one relationships are not yet.
        NSNumber *record_id = [self valueForKey:@"id"];
        if (!record_id) {
            return NO;
        }
        // if synched_at is changed, it must be a change from GET /api/changes or setting id for new record
        // FIXME: this condition seems to be a duplication with a condition in selfChangedValues
//         if ([change valueForKey:@"synched_at"]) {
//             return NO; 
//         }
        
        for (NSString *key in [change allKeys]) {
            id property = [change objectForKey:key];
            if ([property isKindOfClass:[NSManagedObject class]]) { // it implies to-one relationship
                NSNumber *foreign_id = [property valueForKey:@"id"];
                if (!foreign_id) {
                    return NO;
                }
                // replace property and key with it's id
                [change removeObjectForKey:key];
                [change setObject:foreign_id forKey:[key stringByAppendingString:@"_id"]];
            }
        }
        ChangeLog *log = [NSEntityDescription insertNewObjectForEntityForName:@"ChangeLog" inManagedObjectContext:[self managedObjectContext]];
        [log setValue:[change JSONRepresentation] forKey:@"json"];
        [log setValue:[(Class < EntityName >)[self class] entityName] forKey:@"record_type"];
        [log setValue:record_id forKey:@"record_id"];
        [log setTimestamps:nil];
    }
    return YES;
}

- (NSMutableDictionary *)selfChangedValues {
    //NSMutableDictionary *change = [[self changedValues] mutableCopy];
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    [change addEntriesFromDictionary:[self changedValues]];
    // if synched_at is modified, the change seems to be done by sync
    if ([change objectForKey:@"synched_at"]) {
        return nil;
    }
    NSEntityDescription *entity = [self entity];
    // exclude to-many relationships (they don't have related columns), and convert to-one to *_id
    for (NSRelationshipDescription *relationship in [[entity relationshipsByName] allValues]) {
        if ([change objectForKey:[relationship name]]) {
            [change removeObjectForKey:[relationship name]];
            if (![relationship isToMany]) {
                NSString *name = [relationship name];
                NSString *key = [name stringByAppendingString:@"_id"];
                NSNumber *value = [[self valueForKey:name] valueForKey:@"id"];
                [change setValue:value forKey:key];
            }
        }
    }
    if ([change count] == 0)
        return nil;
    return change;
}

- (BOOL)needUpdate {
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

@implementation NSManagedObject ( Convenience )
- (void)setValues:(NSDictionary *)values {
    for (NSString *key in [values allKeys]) {
        [self setValue:[values objectForKey:key] forKey:key];
    }
}
@end
