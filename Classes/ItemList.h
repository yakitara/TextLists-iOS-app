// -*-ObjC-*-
#import <CoreData/CoreData.h>
#import "ResourceProtocol.h"

@class Listing;

@interface ItemList :  NSManagedObject < ResourceSupport, ChangeLog >
{
}
/*
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSSet* listings;
*/
@end

/*
@interface ItemList (CoreDataGeneratedAccessors)
- (void)addListingsObject:(Listing *)value;
- (void)removeListingsObject:(Listing *)value;
- (void)addListings:(NSSet *)value;
- (void)removeListings:(NSSet *)value;

@end
*/
