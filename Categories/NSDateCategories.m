#import "NSDateCategories.h"


@implementation NSDate (JSON)
+ (NSDateFormatter *)JSONDateFormatter:(BOOL)isUTC {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    if (isUTC) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    } else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
    }
    return dateFormatter;
}

+ (NSDate *)dateFromJSONDateString:(NSString *)dateString {
    BOOL isUTC = ([dateString rangeOfString:@"Z" options:NSBackwardsSearch].location != NSNotFound);
    return [[NSDate JSONDateFormatter:isUTC] dateFromString:dateString];
}

- (id)proxyForJson {
    BOOL isUTC = ([[NSTimeZone defaultTimeZone] secondsFromGMT] == 0);
    return [[NSDate JSONDateFormatter:isUTC] stringFromDate:self];
}
@end
