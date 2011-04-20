#import "ChangeLog.h"
#import "ItemsAppDelegate.h"
#import "NSManagedObjectContextCategories.h"
#import "EntityNameProtocol.h"
#import "JSON.h"

@implementation ChangeLog 

//@dynamic record_type;
//@dynamic record_id;
//@dynamic json;
//@dynamic created_at;
// TODO: this method may be a general NSManagedObject method
+ (ChangeLog *)fetchFirst {
    NSManagedObjectContext *context = [UIAppDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChangeLog" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:1];
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:YES] autorelease];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return [[context executeFetchRequest:fetchRequest] lastObject];
}

+ (id)changeForManagedObject:(NSManagedObject <EntityName> *)record {
    if ([record isKindOfClass:[ChangeLog class]]) {
        return record;
    } else {
        id change = [NSMutableDictionary dictionary];
        [change setObject:[[record class] entityName] forKey:@"record_type"];
        [change setObject:[record JSONRepresentation] forKey:@"json"];
        [change setObject:[NSDate date] forKey:@"created_at"];
        return change;
    }
}

#pragma mark -
#pragma mark ChangeLog protocol
- (BOOL)needChangeLog {
    return NO;
}
@end
