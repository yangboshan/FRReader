//
//  UIImage+FRCategory.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/28.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "UIImage+FRCategory.h"

@implementation UIImage (FRCategory)

+ (UIImage *)imageWithColor:(UIColor *)color{
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
