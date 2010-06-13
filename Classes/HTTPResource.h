// ;-*-ObjC-*-
#import <Foundation/Foundation.h>

@interface HTTPResource : NSObject {
}
+ (id)getJSONValueFromURL:(NSURL *)url;
+ (id)postJSONValue:(id)value toURL:(NSURL *)url;
+ (id)putJSONValue:(id)value onURL:(NSURL *)url;
@end
