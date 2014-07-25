//
//  XYSaleItemCell.m
//  BStoreMobile
//
//  Created by Julie on 14-7-15.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYSaleItemCell.h"
#import "XYUtil.h"

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
        [XYUtil showButtonBorder:self.buyButton];
        [XYUtil showButtonBorder:self.navButton];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
