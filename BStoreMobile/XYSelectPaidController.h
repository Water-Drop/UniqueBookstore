//
//  TTSelectPaidController.h
//  TokenTextViewSample
//
//  Created by Julie on 14-8-11.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYViewController.h"

@interface XYSelectPaidController : XYViewController<UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *listPaid;
@property NSMutableArray *listPaidName;

@end
