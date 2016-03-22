`依赖注入(Dependency Injection)`这个词，源于java，但在Cocoa框架中也是十分常见的。
举例来说：
**UIView的初始化方法initWithFrame**

```objc
- (id)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
```

这里的frame传入值，就是所谓的`依赖(Dependency)`，这个View实例化是根据frame注入实现的。
但这种用法有很大的局限性
1. 我们不知道究竟依赖注入的属性有哪些
2. 不可能无限加长方法长度来满足更多的依赖属性

所以我们准备采用字典容器对NSObject类进行依赖注入扩展。
##给NSObject类添加一个Category
```
@interface NSObject (XXXDependencyInjection)

- (nullable id)initWithParams:(nonnull NSDictionary *)params;
- (void)injection:(nonnull NSDictionary*)params;

@end
```
##实现注入方法
```
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
            [self performSelector:selector withObject:value];
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
```

##解释
我们将需要注入的属性，封装到一个字典里，例如：
```
UIViewController* controller = [[UIViewController alloc] initWithParams:@{
                               @"title":@"测试",
                               @"view.backgroundColor":[UIColor whiteColor]
                                                                              }];
```
我们给这个VC注入了两个属性，一个是其title，一个是其View的backgroundColor属性。
字典传入以后，我们读区`params.allKeys`进行遍历，拼装set＋参数名的selector，这里用的是NSSelectorFromString方法:
```
SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[[obj substringToIndex:1] uppercaseString],[obj substringFromIndex:1]]);
```
然后我们判断实例是否可以响应这个set方法，如果可以，则给其赋值。
```
        if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector withObject:value];
#pragma clang diagnostic pop
        }
```
这里的三行clang宏是为了消除编译器的内存泄漏警告，这里因为我们进行了验证，所以不会出现leak。
##KVC实现跨实例赋值
我们注意到上例中还有一句给VC的View改变背景颜色
```
  @"view.backgroundColor":[UIColor whiteColor]
```
这里就用到了KVC的点语法特性，在我们判断到实例不能响应` if ([self respondsToSelector:selector]) `的时候，通过点语法，进行赋值
```
@try {
    [self setValue:value forKeyPath:obj];
}
@catch (NSException *exception) {
    NSLog(@"%@",exception);
   [exception raise];
}
@finally {

}
```
这里添加了异常捕获，因为点语法对属性名称拼写要求是全匹配，否则抛异常，所以要注意。
##优缺点
这样改造过的init方法，优点非常明显，就是绑定更加集中便捷，如果使用的是`storyboard`则可以轻松实现前后端分离。
目前的缺点也很明显，不能告诉开发者哪些属性是必需依赖，另外还不能支持非对象属性的赋值，希望抛砖引玉，大家来改进这段代码。
