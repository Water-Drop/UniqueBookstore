//
//  XYCameraButtons.m
//  BStoreMobile
//
//  Created by Jiguang on 7/29/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYCameraButtons.h"
#import "XYUtil.h"

@interface XYCameraButtons ()

@end

@implementation XYCameraButtons

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
}

- (void)normal
{
    if (iOS7) {
        [XYUtil showButtonBorder:_cartButton];
        [XYUtil showButtonBorder:_infoButton];
    }
    [_cartButton setImageEdgeInsets:UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f)];
    [_infoButton setImageEdgeInsets:UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f)];
    
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:5.0]; //设置矩圆角半径
    //    [self.layer setBorderWidth:1.0];   //边框宽度
    //    CGColorRef colorref = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    //    [self.layer setBorderColor:colorref];//边框颜色
    //    [self.layer setOpacity:0.65f];

}

- (void)focus
{
    [self normal];
    [self.layer setBackgroundColor:[UIColor redColor].CGColor];
    [self.layer setOpacity:0.85f];
    [self.cartButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.infoButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.price setTextColor:[UIColor blackColor]];
}

@end
