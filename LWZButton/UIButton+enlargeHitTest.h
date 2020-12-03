//
//  UIButton+enlargeHitTest.h
//  常驻线程
//
//  Created by 李文仲 on 2020/11/4.
//  Copyright © 2020 CLAY. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (enlargeHitTest)

- (void)setEnlargeEdge:(CGFloat)size;
- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end

NS_ASSUME_NONNULL_END
