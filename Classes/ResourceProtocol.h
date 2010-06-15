//#import <Cocoa/Cocoa.h>

@protocol ResourceSupport
+ (NSString *)resourcePath;
@optional
- (NSString *)resourcePath; // for class objects
@end
