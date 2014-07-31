//
//  XYRoundControl.m
//  BStoreMobile
//
//  Created by Julie on 14-7-31.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYRoundControl.h"

@implementation XYRoundControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
//    if (self.range > 0) {
//        [self.layer setCornerRadius:(self.frame.size.width / self.range)]; //设置矩圆角半径
//        self.layer.masksToBounds = YES;
//    }
    [self.layer setCornerRadius:(self.frame.size.width / 4)]; //设置矩圆角半径
    self.layer.masksToBounds = YES;
}


@end
