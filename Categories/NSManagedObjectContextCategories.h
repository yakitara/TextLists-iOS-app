// ;-*-ObjC-*-
#import <Foundation/Foundation.h>


@interface NSManagedObjectContext ( Convenience )
- (void)save;
- (NSArray *)fetchFromEntityName:(NSString *)entityName withPredicateFormat:(NSString *)predicateFormat argumentArray:(NSArray *)arguments;
//- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest;
@end

@interface NSManagedObjectContext ( Timestamp )
- (void)setRecordTimestamps:(BOOL)recordTimestamp;
@end
