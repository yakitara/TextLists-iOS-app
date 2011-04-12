#import "NSObject+AliasMethodChain.h"
#import <objc/message.h>

@interface TestUserDefaults : NSObject {
    NSMutableDictionary *m_dict;
    NSDictionary *m_registered;
}
+ (TestUserDefaults *)standardUserDefaults;
@end

@implementation TestUserDefaults
+ (TestUserDefaults *)standardUserDefaults {
    static id s_mockDefaults = nil;
    if (!s_mockDefaults) {
        s_mockDefaults = [[self alloc] init];
    }
    return s_mockDefaults;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *orig = objc_msgSend([NSUserDefaults class], @selector(without_mock_standardUserDefaults));
        //m_dict = [[orig dictionaryRepresentation] mutableCopy];
        //m_dict = [[orig volatileDomainForName:NSRegistrationDomain] mutableCopy];
        m_dict = [[NSMutableDictionary alloc] init];
        for (NSString *domain in [orig volatileDomainNames]) {
            NSDictionary *dict = [orig volatileDomainForName:NSRegistrationDomain];
            NSLog(@"volatileDomainForName: %@ => %@", domain, dict);
            [m_dict addEntriesFromDictionary:dict];
        }
    }
    return self;
}

- (void)dealloc {
    [m_dict release];
    [m_registered release];
    [super dealloc];
}

- (void)registerDefaults:(NSDictionary *)dictionary {
    [m_registered release];
    m_registered = [dictionary retain];
    [m_dict addEntriesFromDictionary:m_registered];
}

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithDictionary:m_dict];
}

- (id)objectForKey:(NSString *)defaultName {
    id object = [m_dict objectForKey:defaultName];
    NSLog(@"objectForKey:%@ => %@", defaultName, object);
    return object;
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


// @interface NSUserDefaults (Test)
// @end

@implementation NSUserDefaults (Test)
+ (void)load {
    [self aliasClassMethod:@selector(standardUserDefaults) chainingPrefix:@"mock"];
}

+ (NSUserDefaults *)mock_standardUserDefaults {
    NSLog(@"standardUserDefaults swizzled!");
    return (id)[TestUserDefaults standardUserDefaults];
}
@end
