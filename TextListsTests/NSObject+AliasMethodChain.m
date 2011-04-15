#import "NSObject+AliasMethodChain.h"
#import <objc/runtime.h>
// #import <objc/message.h>

#if _ALIAS_METHOD_CHAIN_TRACER
@interface AliasMethodChainTracer ()
+ (void)createSharedTracer;
+ (void)removeSharedTracer;
+ (AliasMethodChainTracer *)sharedTracer;
+ (void)addClass:(Class)class selector:(SEL)selector prefix:(NSString *)prefix;
+ (void)removeClass:(Class)class selector:(SEL)selector prefix:(NSString *)prefix;
+ (NSDictionary *)dictionaryRepresentationForClass:(Class)class selector:(SEL)selector prefix:(NSString *)prefix;
@end
#endif

static
void aliasMethodChain(Class class, SEL selector, NSString *prefix, IMP newImp) {
#if _ALIAS_METHOD_CHAIN_TRACER
    [AliasMethodChainTracer addClass:class selector:selector prefix:prefix];
#endif
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

static
void revertAliasMethodChain(Class class, SEL selector, NSString *prefix) {
#if _ALIAS_METHOD_CHAIN_TRACER
    [AliasMethodChainTracer removeClass:class selector:selector prefix:prefix];
#endif
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

+ (void)revertAliasInstanceMethod:(SEL)selector chainingPrefix:(NSString *)prefix {
    revertAliasMethodChain([self class], selector, prefix);
}
@end

#if _ALIAS_METHOD_CHAIN_TRACER
static AliasMethodChainTracer *s_tracer = nil;
@implementation AliasMethodChainTracer
@synthesize aliaces;
- (id)init {
    self = [super init];
    if (self) {
        aliaces = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [aliaces release];
    [super dealloc];
}

+ (void)createSharedTracer {
    s_tracer = [[AliasMethodChainTracer alloc] init];
}

+ (void)removeSharedTracer {
    [s_tracer release];
    s_tracer = nil;
}

+ (AliasMethodChainTracer *)sharedTracer {
    return s_tracer;
}

+ (void)addClass:(Class)class selector:(SEL)selector prefix:(NSString *)prefix {
    AliasMethodChainTracer *tracer = [self sharedTracer];
    if (tracer) {
        NSDictionary *info = [self dictionaryRepresentationForClass:class selector:selector prefix:prefix];
        [[self sharedTracer].aliaces addObject:info];
    }
}

+ (void)removeClass:(Class)class selector:(SEL)selector prefix:(NSString *)prefix {
    AliasMethodChainTracer *tracer = [self sharedTracer];
    if (tracer) {
        NSDictionary *info = [self dictionaryRepresentationForClass:class selector:selector prefix:prefix];
        [[self sharedTracer].aliaces removeObject:info];
    }    
}

+ (NSDictionary *)dictionaryRepresentationForClass:(Class)class selector:(SEL)selector prefix:(NSString *)prefix {
    return [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSValue valueWithPointer:class], @"Class",
                            [NSValue valueWithPointer:selector], @"SEL",
                         prefix, @"prefix", nil];
}

+ (void)startTracingAliasesAll {
    [self createSharedTracer];
}

+ (void)revertTracedAliasesAll {
    NSArray *aliaces = [[self sharedTracer].aliaces copy];
    [self removeSharedTracer];
    for (NSDictionary *info in aliaces) {
        revertAliasMethodChain(
            [[info objectForKey:@"Class"] pointerValue],
            [[info objectForKey:@"SEL"] pointerValue],
            [info objectForKey:@"prefix"]);
    }
}
@end
#endif//_ALIAS_METHOD_CHAIN_TRACER
