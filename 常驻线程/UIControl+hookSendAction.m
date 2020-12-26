//
//  UIControl+hookSendAction.m
//  常驻线程
//
//  Created by 李文仲 on 2020/12/26.
//  Copyright © 2020 CLAY. All rights reserved.
//

#import "UIControl+hookSendAction.h"


#import <objc/runtime.h>


@implementation UIControl (hookSendAction)

+ (void)load {
    SEL sel_old = @selector(sendAction:to:forEvent:);
    SEL sel_new = @selector(hookSendAction:to:forEvent:);
    Method method_old = class_getInstanceMethod(self, sel_old);
    Method method_new = class_getInstanceMethod(self, sel_new);
    if (class_addMethod(self, sel_old, method_getImplementation(method_new), method_getTypeEncoding(method_new))) {
        class_replaceMethod(self, sel_new, method_getImplementation(method_old), method_getTypeEncoding(method_old));
    } else {
        method_exchangeImplementations(method_old, method_new);
    }

}

- (void)hookSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    NSLog(@"i've hook UIControl - sendAction!!");
    [self hookSendAction:action to:target forEvent:event];
}

@end
