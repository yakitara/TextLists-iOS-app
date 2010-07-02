#import "Item.h"
#import "Listing.h"
#import "NSManagedObjectCategories.h"

@implementation Item 
/*
@dynamic updated_at;
@dynamic id;
@dynamic content;
@dynamic created_at;
@dynamic listings;
*/
+ (NSString *)resourcePath {
    return @"/api/items";
}
// In principle, an managed object class can be refered by multiple entity, but in most case,
// we can use a managed object class for single entity.
+ (NSString *)entityName {
    return @"Item";
}

#pragma mark -
#pragma mark ChangeLog protocol
- (BOOL)needChangeLog {
    return YES;
}
@end
