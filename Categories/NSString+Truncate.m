#import "NSString+Truncate.h"


@implementation NSString ( Truncate )
// The original code is at http://stackoverflow.com/questions/2266396/how-to-truncate-an-nsstring-based-on-the-graphical-width
- (NSString*)stringByTruncatingStringWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode {
    NSMutableString *resultString = [[self mutableCopy] autorelease];
    NSRange range = {resultString.length-1, 1};
    
    while ([resultString sizeWithFont:font forWidth:FLT_MAX lineBreakMode:lineBreakMode].width > width) {
        // delete the last character
        [resultString deleteCharactersInRange:range];
        range.location--;
        // replace the last but one character with an ellipsis
        [resultString replaceCharactersInRange:range withString:@"…"];
    }
    return resultString;
}
@end
