#import "NSManagedObjectCategories.h"

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

- (void)setTimestamps {
        
    NSDate *now = [NSDate date];
    if (![self valueForKey:@"created_at"]) {
        [self setValue:now forKey:@"created_at"];
    }
    [self setValue:now forKey:@"updated_at"];
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
