//
//  XYLabelChangeController.h
//  BStoreMobile
//
//  Created by Julie on 14-9-5.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

enum labelChangeStatus
{
    NICKNAME, REMAINING, PHONE, AREA, EMAIL
};

@interface XYLabelChangeController : UITableViewController

@property enum labelChangeStatus status;
@property NSString *oldLbl;

@end
