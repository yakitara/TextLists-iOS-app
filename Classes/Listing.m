#import "Listing.h"
#import "NSManagedObjectCategories.h"

@implementation Listing 
/*
@dynamic id;
@dynamic position;
@dynamic deleted_at;
@dynamic created_at;
@dynamic updated_at;
@dynamic list;
@dynamic item;
*/
+ (NSString *)resourcePath {
    return @"/api/listings";
}
// In principle, an managed object class can be refered by multiple entity, but in most case,
// we can use a managed object class for single entity.
+ (NSString *)entityName {
    return @"Listing";
}

- (void)done {
    [self setValue:[NSDate date] forKey:@"deleted_at"];
}

- (NSNumber *)list_id {
    NSManagedObject *list = [self valueForKey:@"list"];
    return list ? [list valueForKey:@"id"] : nil;
}

- (void)setList_id:(NSNumber *)value {
    [self setBelongsTo:@"list" value:value key:@"id" entityName:@"List"];
}

- (NSString *)list_uuid {
    NSManagedObject *list = [self valueForKey:@"list"];
    return list ? [list valueForKey:@"uuid"] : nil;
}

- (void)setList_uuid:(NSString *)value {
    [self setBelongsTo:@"list" value:value key:@"uuid" entityName:@"List"];
}

- (NSNumber *)item_id {
    NSManagedObject *item = [self valueForKey:@"item"];
    return item ? [item valueForKey:@"id"] : nil;
}

- (void)setItem_id:(NSNumber *)value {
    [self setBelongsTo:@"item" value:value key:@"id" entityName:@"Item"];
}

- (NSString *)item_uuid {
    NSManagedObject *item = [self valueForKey:@"item"];
    return item ? [item valueForKey:@"uuid"] : nil;
}

- (void)setItem_uuid:(NSString *)value {
    [self setBelongsTo:@"item" value:value key:@"uuid" entityName:@"Item"];
}

- (void)setDeleted_at:(id)value {
    [self setDate:value forKey:@"deleted_at"];
}

#pragma mark -
#pragma mark ChangeLog protocol
- (BOOL)needChangeLog {
    return YES;
}
@end
