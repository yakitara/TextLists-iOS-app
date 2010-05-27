#import "Item.h"
#import "Listing.h"

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
@end
