//
//  XYGenderChangeController.h
//  BStoreMobile
//
//  Created by Julie on 14-9-5.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYTableViewController.h"

enum genderChangeStatus
{
    GENDER, LOCATION
};

@interface XYGenderChangeController : XYTableViewController

@property NSString *gender;
@property enum genderChangeStatus status;

@end
