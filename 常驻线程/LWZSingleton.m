
//
//  LWZSingleton.m
//  常驻线程
//
//  Created by 李文仲 on 2020/10/10.
//  Copyright © 2020 CLAY. All rights reserved.
//

#import "LWZSingleton.h"

static dispatch_once_t onceToken;
static LWZSingleton *singleton;

@implementation LWZSingleton

+ (instancetype)shareSingleton {
    if (!singleton) {
        singleton = [[self alloc] init];
    }
    return singleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        singleton = [super allocWithZone:zone]; //这里不init, 不过依然是返回id对象
    });
    return singleton;
}

+ (void)tearDown {
    singleton = nil;
    onceToken = 0;
}

//kvo测试
- (void)changeAge {
//    self.age = 666; //会触发kvo
    _age = 233; //不会触发kvo
}

@end
