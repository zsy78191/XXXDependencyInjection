//
//  XXXDependencyInjection.h
//  SimpleDictionary
//
//  Created by 张超 on 16/3/22.
//  Copyright © 2016年 gerinn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XXXDependencyInjection <NSObject>

@end

@interface NSObject (XXXDependencyInjection)

- (nullable id)initWithParams:(nonnull NSDictionary *)params;
- (void)injection:(nonnull NSDictionary*)params;

@end
