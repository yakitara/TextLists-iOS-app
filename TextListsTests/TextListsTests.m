#import "TextListsTests.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface NSObject (AliasMethodCHain)
/*
    Example:
    @implementation NSUserDefaults (Log)
    + (void)load {
        [self aliasClassMethod:@selector(standardUserDefaults) chainingPrefix:@"log"];
    }
    + (NSUserDefaults *)log_standardUserDefaults {
        NSLog(@"standardUserDefaults swizzled!");
        return objc_msgSend(self, @selector(without_log_standardUserDefaults));
    }
    @end
*/
+ (void)aliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix;
@end

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



@interface MockUserDefaults : NSObject {
    NSMutableDictionary *m_dict;
    NSDictionary *m_registered;
}
+ (MockUserDefaults *)standardUserDefaults;
@end
@implementation MockUserDefaults
+ (MockUserDefaults *)standardUserDefaults {
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

- (id)objectForKey:(NSString *)defaultName {
    id object = [m_dict objectForKey:defaultName];
    NSLog(@"objectForKey:%@ => %@", defaultName, object);
    return object;
}

- (void)registerDefaults:(NSDictionary *)dictionary {
    [m_registered release];
    m_registered = [dictionary retain];
    [m_dict addEntriesFromDictionary:m_registered];
}

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithDictionary:m_dict];
}

#if 1
+ (BOOL)resolveInstanceMethod:(SEL)selector {
    const char* name = sel_getName(selector);
    NSLog(@"resolveInstanceMethod:@selector(%s)", name);
    return NO;
}
#endif
@end


@implementation NSUserDefaults (Mock)
+ (void)load {
    NSLog(@"mock load");
    [self aliasClassMethod:@selector(standardUserDefaults) chainingPrefix:@"mock"];
    //[self aliasClassMethod:@selector(resetStandardUserDefaults) chainingPrefix:@"mock"];
}

+ (NSUserDefaults *)mock_standardUserDefaults {
    NSLog(@"standardUserDefaults swizzled!");
    //return objc_msgSend(self, @selector(without_mock_standardUserDefaults));
    return (id)[MockUserDefaults standardUserDefaults];
}
@end



@implementation TextListsTests
- (void)setUp
{
    [super setUp];
    // Set-up code here.
    NSLog(@"setup");
}

- (void)tearDown
{
    // Tear-down code here.
    NSLog(@"tearDown");
    [super tearDown];
}

- (void)testAppDelegate
{
    id appDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(appDelegate, @"Cannot find the application delegate");
//    STFail(@"Unit tests are not implemented yet in TextListsTests");
}
@end
