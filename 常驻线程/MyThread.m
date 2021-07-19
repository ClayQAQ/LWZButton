//
//  MyThread.m
//  常驻线程
//
//  Created by 李文仲 on 2021/7/9.
//  Copyright © 2021 CLAY. All rights reserved.
//

#import "MyThread.h"

@implementation MyThread

- (void)dealloc {
    NSLog(@"Dealloc --- my thread!!!");
}

@end
