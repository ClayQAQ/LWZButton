//
//  AsyncView.m
//  常驻线程
//
//  Created by 李文仲 on 2021/9/2.
//  Copyright © 2021 CLAY. All rights reserved.
//

#import "AsyncView.h"

@implementation AsyncView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//            //得到ctx
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        UIImage *myImage = [UIImage imageNamed:@"test"];
//        CGRect myRect = CGRectMake(0, 0, myImage.size.width, myImage.size.height);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //画进当前ctx
//            CGContextDrawImage(context, myRect, myImage.CGImage);
//        });
//    });


    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *myImage = [UIImage imageNamed:@"test"];
    CGRect myRect = CGRectMake(0, 0, myImage.size.width, myImage.size.height);
    CGContextDrawImage(context, myRect, myImage.CGImage);
}


@end
