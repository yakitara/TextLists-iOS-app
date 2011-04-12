// -*- ObjC -*-

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
@interface NSObject (AliasMethodCHain)
+ (void)aliasClassMethod:(SEL)selector chainingPrefix:(NSString *)prefix;
@end
