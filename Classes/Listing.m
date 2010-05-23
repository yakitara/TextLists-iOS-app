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

- (NSNumber *)list_id {
    NSManagedObject *list = [self valueForKey:@"list"];
    return list ? [list valueForKey:@"id"] : nil;
}

- (void)setList_id:(NSNumber *)value {
    [self setBelongsToId:value forKey:@"list" entityName:@"List"];
}

- (NSNumber *)item_id {
    NSManagedObject *item = [self valueForKey:@"item"];
    return item ? [item valueForKey:@"id"] : nil;
}

- (void)setItem_id:(NSNumber *)value {
    [self setBelongsToId:value forKey:@"item" entityName:@"Item"];
}

@end
