#import "NSErrorCategories.h"


@implementation NSError (PrettyPrint)
- (void)prettyPrint {
    NSLog(@"unresolved error(s): %@", self);
    NSArray *detailErrors = [[self userInfo] objectForKey:@"NSDetailedErrors"];
    if (detailErrors) {
        for (NSError *detailError in [[self userInfo] objectForKey:@"NSDetailedErrors"]) {
            NSLog(@"detail error: %@", [detailError userInfo]);
        }
    } else {
        NSLog(@"detail error: %@", [self userInfo]);
    }
}
@end
