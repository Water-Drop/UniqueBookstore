//
//  XYBookInfoMainCell.m
//  BStoreMobile
//
//  Created by Julie on 14-7-17.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYBookInfoMainCell.h"

#define iOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0

@implementation XYBookInfoMainCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (iOS7) {
        [self showButtonBorder:self.buyButton];
        [self showButtonBorder:self.navButton];
    }
}

- (void)showButtonBorder: (UIButton *)button
{
    // used in iOS 7
    if ([button isKindOfClass:[UIButton class]]) {
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:5.0]; //设置矩圆角半径
        [button.layer setBorderWidth:1.0];   //边框宽度
        CGColorRef colorref = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
        [button.layer setBorderColor:colorref];//边框颜色
    }
}

@end
