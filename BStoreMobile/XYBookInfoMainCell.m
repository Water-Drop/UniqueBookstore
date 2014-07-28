//
//  XYBookInfoMainCell.m
//  BStoreMobile
//
//  Created by Julie on 14-7-17.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYBookInfoMainCell.h"
#import "XYUtil.h"

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
        [XYUtil showButtonBorder:self.buyButton];
        [XYUtil showButtonBorder:self.navButton];
        [XYUtil showButtonBorder:self.toBuyButton];
    }
}

@end
