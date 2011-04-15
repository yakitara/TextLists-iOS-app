// -*- ObjC -*-

/*
    You know OCMock does great, but (If I'm not get wrong with it)
    - it will supposed to be used in tests not a production code
    - it can't mock class methods
    - it requires an instace to be mocked accessible in your tests
    
    If you not familiar with alias_method_chain, see:
    https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/module/aliasing.rb
    
    Examples
    --------
    // Example 1 (using category):
    @implementation NSUserDefaults (Log)
    + (void)load {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [self aliasClassMethod:@selector(standardUserDefaults) chainingPrefix:@"log"];
        [pool release];
    }
    + (NSUserDefaults *)log_standardUserDefaults {
        NSLog(@"standardUserDefaults swizzled!");
        return objc_msgSend(self, @selector(without_log_standardUserDefaults));
    }
    @end
    
    // Example 2 (using block):
    [self aliasClassMethod:@selector(standardUserDefaults) chainingPrefix:@"log" withBlock:^(id _class) {
        NSLog(@"standardUserDefaults swizzled!");
        return objc_msgSend(_class, @selector(without_log_standardUserDefaults));
    }];
*/
@interface NSObject (AliasMethodChain)
+ (void)aliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix;
+ (void)aliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix withBlock:(void *)block;
+ (void)revertAliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix;

+ (void)aliasInstanceMethod:(SEL)selector chainingPrefix:(NSString *)prefix;
+ (void)aliasInstanceMethod:(SEL)selector chainingPrefix:(NSString *)prefix withBlock:(void *)block;
+ (void)revertAliasInstanceMethod:(SEL)selector chainingPrefix:(NSString *)prefix;
@end

/*
    Example: Revert all aliases after setUp on tearDown
    @implementation ExampleTests
    - (void)setUp {
        [super setUp];
        [AliasMethodChainTracer startTracingAliasesAll];
    }
    - (void)tearDown {
        // revert method swizzling of +[ASIHTTPRequest requestWithURL] for another test case...
        [AliasMethodChainTracer revertTracedAliasesAll];
        [super tearDown];
    }
    - (void)testSync {
        [ASIHTTPRequest aliasClassMethod:@selector(requestWithURL:) chainingPrefix:@"mock"];
        [[[NSApplication sharedApplication] delegate] sync];
    }
    @end
*/
#define _ALIAS_METHOD_CHAIN_TRACER 1
#if _ALIAS_METHOD_CHAIN_TRACER
@interface AliasMethodChainTracer : NSObject
{
    NSMutableArray *aliaces;
}
@property (nonatomic, retain, readonly) NSMutableArray *aliaces;
+ (void)startTracingAliasesAll;
+ (void)revertTracedAliasesAll;
@end
#endif //_ALIAS_METHOD_CHAIN_TRACER
