#import <Foundation/Foundation.h>


@interface NSString (Truncate)
- (NSString*)stringByTruncatingStringWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode;
@end
