//
//  UIColor+hexColor.m
//  RecordDemo
//
//  Created by reylen on 16/8/10.
//  Copyright © 2016年 reylen. All rights reserved.
//

#import "UIColor+hexColor.h"

@implementation UIColor (hexColor)

+ (UIColor*) r_colorWithHex:(NSInteger) hexValue {
    return [UIColor r_colorWithHex:hexValue alpha:1];
}

+ (UIColor*) r_colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

@end
