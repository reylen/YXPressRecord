//
//  UIColor+hexColor.h
//  RecordDemo
//
//  Created by reylen on 16/8/10.
//  Copyright © 2016年 reylen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (hexColor)

+ (UIColor*) r_colorWithHex:(NSInteger) hexValue;
+ (UIColor*) r_colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;

@end
