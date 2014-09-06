//
//  XYBookInfoMainCell.h
//  BStoreMobile
//
//  Created by Julie on 14-7-17.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYBookInfoMainCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *navButton;
@property (weak, nonatomic) IBOutlet UIButton *toBuyButton;
@property (weak, nonatomic) IBOutlet UILabel *cntScore;
@property (weak, nonatomic) IBOutlet UIView *totScoreView;
@property (weak, nonatomic) IBOutlet UIButton *weiboBtn;

@end
