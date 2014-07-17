//
//  XYSaleItemCell.m
//  BStoreMobile
//
//  Created by Julie on 14-7-15.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYSaleItemCell.h"

#define iOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0

@implementation XYSaleItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (iOS7) {
        NSLog(@"AwakeFromNib");
        [self showButtonBorder:self.buyButton];
        [self showButtonBorder:self.navButton];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
