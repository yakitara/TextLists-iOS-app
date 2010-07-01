#import "ItemList.h"
#import "Listing.h"

@implementation ItemList 
/*
@dynamic id;
@dynamic name;
@dynamic position;
@dynamic created_at;
@dynamic updated_at;
@dynamic listings;
*/

+ (NSString *)resourcePath {
    return @"/api/lists";
}

// In principle, an managed object class can be refered by multiple entity, but in most case,
// we can use a managed object class for single entity.
+ (NSString *)entityName {
    return @"List";
}

// an unsynchronized (means no "id") object with same name of given values assumes identical
+ (ItemList *)fetchObjectIdenticalToValues:(NSDictionary *)values inManagedObjectContext:(NSManagedObjectContext *)context {
    NSString *name = [values objectForKey:@"name"];
    return [[context fetchFromEntityName:[self entityName] withPredicateFormat:@"name == %@" argumentArray:[NSArray arrayWithObject:name]] lastObject];
}
#pragma mark -
#pragma mark ChangeLog protocol
- (BOOL)needChangeLog {
    return YES;
}
@end
