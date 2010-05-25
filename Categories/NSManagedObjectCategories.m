#import "NSManagedObjectCategories.h"

@implementation NSManagedObject ( TimeStamps )
- (void)setUpdated_at:(id)value {
    [self setDate:value forKey:@"updated_at"];
}

- (void)setCreated_at:(id)value {
    [self setDate:value forKey:@"created_at"];
}

- (void)setDate:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSString class]]) {
//        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        value = [[NSDate JSONDateFormatter] dateFromString:value];
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

@implementation NSManagedObject (Association )
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
