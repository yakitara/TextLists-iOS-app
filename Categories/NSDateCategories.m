#import "NSDateCategories.h"


@implementation NSDate (JSON)
+ (NSDateFormatter *)JSONDateFormatter {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    return dateFormatter;
}

- (id)proxyForJson {
    return [[NSDate JSONDateFormatter] stringFromDate:self];
}
@end
