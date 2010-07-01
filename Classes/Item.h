// -*-ObjC-*-
#import <CoreData/CoreData.h>
#import "ResourceProtocol.h"

@class Listing;

@interface Item :  NSManagedObject  < ResourceSupport, ChangeLog, EntityName >
{
}
/*
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSSet* listings;
*/
@end

/*
@interface Item (CoreDataGeneratedAccessors)
- (void)addListingsObject:(Listing *)value;
- (void)removeListingsObject:(Listing *)value;
- (void)addListings:(NSSet *)value;
- (void)removeListings:(NSSet *)value;

@end
*/
