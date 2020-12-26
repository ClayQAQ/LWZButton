//
//  SendActionBtn.m
//  常驻线程
//
//  Created by 李文仲 on 2020/12/26.
//  Copyright © 2020 CLAY. All rights reserved.
//

#import "SendActionBtn.h"

@implementation SendActionBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [super sendAction:action to:target forEvent:event]; //若这个注释掉, 则此按钮无法响应.
}

@end
