#import "NSObject+AliasMethodChain.h"
#import <objc/runtime.h>
// #import <objc/message.h>

static
void aliasMethodChain(Class class, SEL selector, NSString *prefix, IMP newImp) {
    Method method = class_isMetaClass(class) ? class_getClassMethod(class, selector) : class_getInstanceMethod(class, selector);
    const char * types = method_getTypeEncoding(method);
    const char* name = sel_getName(selector);
    
    SEL newImpSelector = sel_registerName([[NSString stringWithFormat:@"%@_%s", prefix, name] UTF8String]);
    if (newImp) {
        class_addMethod(class, newImpSelector, newImp, types);
    } else {
        newImp = class_getMethodImplementation(class, newImpSelector);
    }
    IMP origImp = class_replaceMethod(class, selector, newImp, types);
    SEL origImpSelector = sel_registerName([[NSString stringWithFormat:@"without_%@_%s", prefix, name] UTF8String]);
    class_addMethod(class, origImpSelector, origImp, types);
}

void revertAliasMethodChain(Class class, SEL selector, NSString *prefix) {
    Method method = class_isMetaClass(class) ? class_getClassMethod(class, selector) : class_getInstanceMethod(class, selector);
    const char * types = method_getTypeEncoding(method);
    SEL origImpSelector = sel_registerName([[NSString stringWithFormat:@"without_%@_%s", prefix, sel_getName(selector)] UTF8String]);
    IMP origImp = class_getMethodImplementation(class, origImpSelector);
    class_replaceMethod(class, selector, origImp, types);
}

@implementation NSObject (AliasMethodChain)
+ (void)aliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix {
    aliasMethodChain(object_getClass(self), selector, prefix, nil);
}

+ (void)aliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix withBlock:(void *)block {
    // CREDIT: http://www.friday.com/bbum/2011/03/17/ios-4-3-imp_implementationwithblock/
    aliasMethodChain(object_getClass(self), selector, prefix, imp_implementationWithBlock(block));
}

+ (void)revertAliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix {
    revertAliasMethodChain(object_getClass(self), selector, prefix);
}

+ (void)aliasInstanceMethod:(SEL)selector chainingPrefix:(NSString *)prefix {
    aliasMethodChain([self class], selector, prefix, nil);
}

+ (void)aliasInstanceMethod:(SEL)selector chainingPrefix:(NSString *)prefix withBlock:(void *)block {
    // CREDIT: http://www.friday.com/bbum/2011/03/17/ios-4-3-imp_implementationwithblock/
    aliasMethodChain([self class], selector, prefix, imp_implementationWithBlock(block));
}
@end
