//
//  XYUtil.h
//  BStoreMobile
//
//  Created by Julie on 14-7-24.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <Foundation/Foundation.h>

#define iOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0

@interface XYUtil : NSObject

+ (void) parseJsonTest;

+ (NSDictionary *) parseRecBookInfo;

+ (void)showButtonBorder: (UIButton *)button;

@end
