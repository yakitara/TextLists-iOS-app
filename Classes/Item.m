//
//  Item.m
//  items
//
//  Created by hiroshi on 10/05/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

@interface Item ()
- (void)setDate:(id)value forKey:(NSString*)key;
@end

@implementation Item
//@dynamic updated_at;

- (void)setUpdated_at:(id)value {
    [self setDate:value forKey:@"updated_at"];
}

- (void)setCreated_at:(id)value {
    [self setDate:value forKey:@"created_at"];
}

- (void)setDate:(id)value forKey:(NSString*)key {
    if ([value isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        value = [dateFormatter dateFromString:value];
    }
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:value forKey:key];
    [self didChangeValueForKey:key];
}
@end
