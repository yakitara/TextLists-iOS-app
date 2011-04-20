// -*-ObjC-*-
#import <CoreData/CoreData.h>

@protocol EntityName;
@interface ChangeLog :  NSManagedObject
{
}

//@property (nonatomic, retain) NSString * record_type;
//@property (nonatomic, retain) NSNumber * record_id;
//@property (nonatomic, retain) NSString * json;
//@property (nonatomic, retain) NSDate * created_at;
+ (ChangeLog *)fetchFirst;
+ (id)changeForManagedObject:(NSManagedObject <EntityName> *)record;
@end
