//
//  LWZSingleton.h
//  常驻线程
//
//  Created by 李文仲 on 2020/10/10.
//  Copyright © 2020 CLAY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWZSingleton : NSObject
{
    NSInteger _height;
}

@property (nonatomic, assign) NSInteger age;

+ (instancetype)shareSingleton;

+ (void)tearDown;

@end

NS_ASSUME_NONNULL_END
