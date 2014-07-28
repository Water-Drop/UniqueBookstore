//
//  XYCartItemCell.m
//  BStoreMobile
//
//  Created by Julie on 14-7-24.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYCartItemCell.h"
#import "XYUtil.h"

@implementation XYCartItemCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    if (iOS7) {
        [XYUtil showButtonBorder:self.tobuyBtn];
    }
}

@end
