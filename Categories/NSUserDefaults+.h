// -*- ObjC -*-
#import <Foundation/Foundation.h>


@interface NSUserDefaults (DjVuFiles)
+ (void)registerAppDefaults:(NSString *)fileName;
+ (void)resetToAppDefaults;
@end
