#import "NSDateCategories.h"


@implementation NSDate (JSON)
+ (NSDateFormatter *)JSONDateFormatter:(BOOL)isUTC {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    if (isUTC) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    } else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
    }
    return dateFormatter;
}

- (id)proxyForJson {
    BOOL isUTC = ([[NSTimeZone defaultTimeZone] secondsFromGMT] == 0);
    return [[NSDate JSONDateFormatter:isUTC] stringFromDate:self];
}
@end
