#import "NSUserDefaults+.h"

@interface NSUserDefaults ()
+ (NSDictionary *)settingsDefaults;
@end

@implementation NSUserDefaults (private)
+ (void)registerAppDefaults:(NSString *)fileName {
    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];
    NSMutableDictionary *mergedDefaults = [appDefaults mutableCopy];
    NSDictionary *settingsDefaults = [self settingsDefaults];
    // overwrite value of settings for keys
    for (NSString *key in [settingsDefaults keyEnumerator]) {
        [mergedDefaults setObject:[settingsDefaults objectForKey:key] forKey:key];
    }
    [[self standardUserDefaults] registerDefaults:mergedDefaults];
}

+ (void)resetToAppDefaults {
    [[self standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [self resetStandardUserDefaults];
}

+ (void)persistArgumentForKey:(NSString *)defaultName {
    NSUserDefaults *defaults = [self standardUserDefaults];
    id value = [[defaults volatileDomainForName:NSArgumentDomain] objectForKey:defaultName];
    if (value) {
        [defaults setObject:value forKey:defaultName];
    }
}

#pragma mark private
// CREDIT: http://stackoverflow.com/questions/510216
+ (NSDictionary *)settingsDefaults {
    NSString *settingsBundlePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSString *settingsPlistPath = [NSBundle pathForResource:@"Root" ofType:@"plist" inDirectory:settingsBundlePath];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:settingsPlistPath];
    if (settings) {
        NSMutableDictionary *settingsDefaults = [[NSMutableDictionary alloc] initWithCapacity:[settings count]];
        for (NSDictionary *prefSpecification in [settings objectForKey:@"PreferenceSpecifiers"])
        {
            NSString *key = [prefSpecification objectForKey:@"Key"];
            id value = [prefSpecification objectForKey:@"DefaultValue"];
            if (key && value)
            {
                [settingsDefaults setObject:value forKey:key];
            }
        }
        return settingsDefaults;
    }
    return nil;
}
@end
