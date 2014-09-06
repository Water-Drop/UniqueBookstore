//
//  XYSelectThemeController.h
//  BStoreMobile
//
//  Created by Julie on 14-9-6.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYViewController.h"

@interface XYSelectThemeController : XYViewController<UITableViewDataSource, UITableViewDelegate>

@property NSString *tagName;
@property NSString *tagID;

@end
