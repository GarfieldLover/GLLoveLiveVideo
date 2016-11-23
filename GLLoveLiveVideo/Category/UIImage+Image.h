//
//  UIControl+Extension.m
//   
//
//  Created by ZK on 16/7/3.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Image)

// 加载不要被渲染的图片
+ (UIImage *)imageWithOriginalRenderingMode:(NSString *)imageName;

@end
