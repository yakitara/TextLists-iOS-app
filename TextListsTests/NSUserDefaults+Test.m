#import "NSObject+AliasMethodChain.h"
#import <objc/message.h>

@interface TestUserDefaults : NSObject {
    NSMutableDictionary *m_dict;
}
+ (TestUserDefaults *)standardUserDefaults:(BOOL)reset;
@end

@implementation TestUserDefaults
+ (TestUserDefaults *)standardUserDefaults:(BOOL)reset {
    static id s_mockDefaults = nil;
    if (reset) {
        [s_mockDefaults release];
        s_mockDefaults = nil;
    }
    if (!s_mockDefaults) {
        s_mockDefaults = [[self alloc] init];
    }
    return s_mockDefaults;
}

- (id)init {
    self = [super init];
    if (self) {
        m_dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [m_dict release];
    [super dealloc];
}

- (void)registerDefaults:(NSDictionary *)dictionary {
    NSUserDefaults *orig = objc_msgSend([NSUserDefaults class], @selector(without_test_standardUserDefaults));
    [orig registerDefaults:dictionary];
}

- (NSDictionary *)dictionaryRepresentation {
    // NOTE: It is needed merge volatileDomains on demand
    NSMutableDictionary *tmp = [m_dict mutableCopy];
    NSUserDefaults *orig = objc_msgSend([NSUserDefaults class], @selector(without_test_standardUserDefaults));
    for (NSString *domain in [orig volatileDomainNames]) {
        NSDictionary *dict = [orig volatileDomainForName:domain];
        //NSLog(@"volatileDomainForName: %@ => %@", domain, dict);
        [tmp addEntriesFromDictionary:dict];
    }
    return tmp;
}

- (id)objectForKey:(NSString *)defaultName {
    id value = [[self dictionaryRepresentation] objectForKey:defaultName];
    //NSLog(@"TestUserDefaults objectForKey:%@ => %@", defaultName, value);
    return value;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
    //NSLog(@"TestUserDefaults setObject:%@ forKey:%@", value, defaultName);
    [m_dict setObject:value forKey:defaultName];
}

- (BOOL)synchronize {
    return YES;
}

- (NSInteger)integerForKey:(NSString *)defaultName {
    return [[self objectForKey:defaultName] integerValue];
}

- (BOOL)boolForKey:(NSString *)defaultName {
    return [[self objectForKey:defaultName] boolValue];
}

#if 1
+ (BOOL)resolveInstanceMethod:(SEL)selector {
    const char* name = sel_getName(selector);
    NSLog(@"resolveInstanceMethod:@selector(%s)", name);
    BOOL resolved = [super resolveInstanceMethod:selector];
    if (!resolved) {
        SEL objectForKeys[] = {@selector(stringForKey:)};
        for (int i = 0; i < sizeof(objectForKeys)/sizeof(SEL); i++) {
            if (selector == objectForKeys[i]) {
                IMP imp = class_getMethodImplementation([self class], @selector(objectForKey:));
                const char * types = method_getTypeEncoding(class_getClassMethod([self class], @selector(objectForKey:)));
                class_addMethod([self class], selector, imp, types);
                return YES;
            }
        }
    }
    return resolved;
}
#endif
@end


@implementation NSUserDefaults (Test)
+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self aliasClassMethod:@selector(standardUserDefaults) chainingPrefix:@"test"];
    [self aliasClassMethod:@selector(resetToAppDefaults) chainingPrefix:@"test"];
    [pool release];
}

+ (NSUserDefaults *)test_standardUserDefaults {
    //NSLog(@"standardUserDefaults swizzled!");
    return (id)[TestUserDefaults standardUserDefaults:NO];
}

+ (void)test_resetToAppDefaults {
    [TestUserDefaults standardUserDefaults:YES];
}
@end
