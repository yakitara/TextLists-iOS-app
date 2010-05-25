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

 - (id)proxyForJson {
     NSMutableDictionary *dict = [NSMutableDictionary dictionary];
     for (NSString *attr in [[[self entity] attributesByName] allKeys]) {
         [dict setValue:[self valueForKey:attr] forKey:attr];
     }
     NSLog(@"proxyForJson:%@", dict);
     return dict;
 }

@end
