#import <CoreData/CoreData.h>

@interface NSManagedObject ( TimeStamps )
- (void)setDate:(id)value forKey:(NSString *)key;
@end

@interface NSManagedObject (Association )
- (void)setBelongsToId:(id)value forKey:(NSString *)key entityName:(NSString *)entityName;
@end
