#import "NSObject+AliasMethodChain.h"
#import <objc/runtime.h>
// #import <objc/message.h>


@implementation NSObject (AliasMethodCHain)
+ (void)aliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    id metaclass = object_getClass(self);
    const char* name = sel_getName(selector);
    const char * types = method_getTypeEncoding(class_getClassMethod(metaclass, selector));
    
    NSString *prefixedName = [NSString stringWithFormat:@"%@_%s", prefix, name];
    SEL prefixedSelector = sel_registerName([prefixedName UTF8String]);
    IMP prefixedImp = class_getMethodImplementation(metaclass, prefixedSelector);
    IMP origImp = class_replaceMethod(metaclass, selector, prefixedImp, types);
    NSString *withoutPrefixedName = [NSString stringWithFormat:@"without_%@_%s", prefix, name];
    SEL withoutPrefixedSelector = sel_registerName([withoutPrefixedName UTF8String]);
    class_addMethod(metaclass, withoutPrefixedSelector, origImp, types);
    [pool release];
}
@end
