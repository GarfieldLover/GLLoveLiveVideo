//
//  UIControl+Extension.m
//   
//
//  Created by ZK on 16/7/3.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "UIImage+Image.h"

@implementation UIImage (Image)
+ (UIImage *)imageWithOriginalRenderingMode:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
@end
