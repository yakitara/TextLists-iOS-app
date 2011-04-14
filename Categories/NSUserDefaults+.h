// -*- ObjC -*-
#import <Foundation/Foundation.h>


@interface NSUserDefaults (AppDefaults)
+ (void)registerAppDefaults:(NSString *)fileName;
+ (void)resetToAppDefaults;
@end
