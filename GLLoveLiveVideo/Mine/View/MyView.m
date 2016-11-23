//
//  MyView.m
//   
//
//  Created by ZK on 16/7/4.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "MyView.h"

@implementation MyView

//hitTest的作用:当在一个view上添加一个屏蔽罩，但又不影响对下面   view的操作，也就是可以透过屏蔽罩对下面的view进行操作，这个函数就很好用了。



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        return nil;
    } else {
        return result;
    }
}

@end
