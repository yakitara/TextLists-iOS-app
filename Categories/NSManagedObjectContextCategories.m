#import "NSManagedObjectContextCategories.h"

@implementation NSManagedObjectContext (ErrorHandling)
- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest {
    NSError *error = nil;
    NSArray *records = [self executeFetchRequest:fetchRequest error:&error];
    if (!records) {
        [error prettyPrint];
        abort();
    }
    return records;
}

- (void)save {
    NSError *error = nil;
    if (![self save:&error]) {
        /*
            Replace this implementation with code to handle the error appropriately.
            
            abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
        */
        [error prettyPrint];
        abort();
    }
}
@end
