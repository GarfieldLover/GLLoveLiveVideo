//
//  MiddleView.m
//   
//
//  Created by ZK on 16/7/3.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "MiddleView.h"

@implementation MiddleView

+ (instancetype)middleView {
      return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}

@end
