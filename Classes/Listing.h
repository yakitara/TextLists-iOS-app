// -*-ObjC-*-
#import <CoreData/CoreData.h>
#import "ResourceProtocol.h"
#import "ChangeLogProtocol.h"
#import "EntityNameProtocol.h"

@interface Listing :  NSManagedObject < ResourceSupport, ChangeLog, EntityName >
{
}
@property (nonatomic, assign) NSNumber *list_id;
@property (nonatomic, assign) NSNumber *item_id;
@property (nonatomic, assign) NSString *list_uuid;
@property (nonatomic, assign) NSString *item_uuid;
- (void)done;
/*
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSDate * deleted_at;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSManagedObject * list;
@property (nonatomic, retain) NSManagedObject * item;
*/
@end



