//
//  XYUtil.h
//  BStoreMobile
//
//  Created by Julie on 14-7-24.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <Foundation/Foundation.h>

#define iOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0

static NSString * const BASEURLSTRING = @"http://218.244.128.72:8080/BookStoreService/";

// static NSString * USERID = @"1";

static NSString * defaultFontName = @"Helvetica Neue";

@interface XYUtil : NSObject

+ (void)parseJsonTest;

+ (NSDictionary *)parseRecBookInfo;

+ (void)showButtonBorder: (UIButton *)button;

+ (NSString *)printMoneyAtCent:(int) moneyAtCent;

+ (void)setExtraCellLineHidden: (UITableView *)tableView;

+ (NSString *)getUserID;

+ (BOOL)isPureInt:(NSString*)string;

+ (BOOL)isPureFloat:(NSString*)string;

@end
