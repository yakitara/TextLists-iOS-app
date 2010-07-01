// -*-ObjC-*-
#import <CoreData/CoreData.h>


@interface ChangeLog :  NSManagedObject < ChangeLog >
{
}

//@property (nonatomic, retain) NSString * record_type;
//@property (nonatomic, retain) NSNumber * record_id;
//@property (nonatomic, retain) NSString * json;
//@property (nonatomic, retain) NSDate * created_at;
+ (ChangeLog *)fetchFirst;
@end
