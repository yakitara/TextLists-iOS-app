#import <Foundation/Foundation.h>


@interface NSDate (JSON)
+ (NSDateFormatter *)JSONDateFormatter:(BOOL)isUTC;
+ (NSDate *)dateFromJSONDateString:(NSString *)dateString;
@end
