//
//  XYPaidItemCell.m
//  BStoreMobile
//
//  Created by Julie on 14-7-25.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYPaidItemCell.h"
#import "XYUtil.h"

@implementation XYPaidItemCell

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
        [XYUtil showButtonBorder:self.comButton];
    }
}

@end
