#import "NSURL+QueryDictionary.h"


@implementation NSURL (QueryDictionary)
- (NSDictionary *)queryDictionary {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSString *param in [[self query] componentsSeparatedByString:@"&"]) {
        NSArray *pair = [param componentsSeparatedByString:@"="];
        NSString *key = [pair objectAtIndex:0];
        NSString *value = [pair objectAtIndex:1];
        [params setObject:value forKey:key];
    }
    return params;
}
@end
