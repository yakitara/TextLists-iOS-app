#import <Foundation/Foundation.h>


@interface NSDate (JSON)
+ (NSDateFormatter *)JSONDateFormatter:(BOOL)isUTC;
@end
