// ;-*-ObjC-*-
#import <CoreData/CoreData.h>

@interface NSManagedObject ( TimeStamps )
- (void)setDate:(id)value forKey:(NSString *)key;
- (void)setTimestamps;
@end

@interface NSManagedObject ( Association )
- (void)setBelongsToId:(id)value forKey:(NSString *)key entityName:(NSString *)entityName;
@end

@interface NSManagedObject ( Identity )
- (BOOL)isIdentical:(NSManagedObject*)anManagedObject;
@end

@interface NSManagedObject ( UndefinedKey )
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
@end

@protocol NSManagedObjectClassFetch
- (NSManagedObject *)fetchObjectIdenticalToValues:(NSDictionary *)values inManagedObjectContext:(NSManagedObjectContext *)context;
@end
