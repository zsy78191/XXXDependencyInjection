//
//  XXXDependencyInjection.m
//  SimpleDictionary
//
//  Created by 张超 on 16/3/22.
//  Copyright © 2016年 gerinn. All rights reserved.
//

#import "XXXDependencyInjection.h"

@implementation NSObject(XXXDependencyInjection)

- (id)initWithParams:(NSDictionary *)params
{
    self = [self init];
    if (self) {
        [self injection:params];
    }
    return self;
}

- (void)injection:(NSDictionary*)params
{
    [params.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[[obj substringToIndex:1] uppercaseString],[obj substringFromIndex:1]]);
        id value = [params objectForKey:obj];
        
        
        if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            [self performSelector:selector withObject:value];
            [self setValue:value forKeyPath:obj];
#pragma clang diagnostic pop
        }
        else
        {
            @try {
                [self setValue:value forKeyPath:obj];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
                [exception raise];
            }
            @finally {
                
            }
        }
    }];
}

@end