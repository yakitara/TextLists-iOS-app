// ;-*-ObjC-*-
#import <Foundation/Foundation.h>


@interface NSManagedObjectContext (ErrorHandling)
- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest;
- (void)save;
@end
