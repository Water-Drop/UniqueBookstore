//
//  XYOrderHeadView.h
//  XYTest
//
//  Created by Julie on 14-8-13.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYRoundView.h"

@interface XYInvoiceView : UIView

@property (weak, nonatomic) IBOutlet UILabel *orderID;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *bookStore;
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *totCnt;
@property (weak, nonatomic) IBOutlet UILabel *totPrice;
@property (weak, nonatomic) IBOutlet UILabel *orderTimePrompt;
@property (weak, nonatomic) IBOutlet UILabel *totCntPrompt;
@property (weak, nonatomic) IBOutlet UILabel *prompt;

@end
