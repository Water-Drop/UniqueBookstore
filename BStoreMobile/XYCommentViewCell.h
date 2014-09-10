//
//  XYCommentViewCell.h
//  BStoreMobile
//
//  Created by Julie on 14-7-27.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYAutoLayoutLabel.h"

@interface XYCommentViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *uname;
@property (weak, nonatomic) IBOutlet XYAutoLayoutLabel *content;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UILabel *pubDate;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UILabel *upCnt;
@property (weak, nonatomic) IBOutlet UILabel *downCnt;
@property (weak, nonatomic) IBOutlet UILabel *fromlbl;
@property (weak, nonatomic) IBOutlet UILabel *publicMsg;



@end
