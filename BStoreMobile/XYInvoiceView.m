//
//  XYOrderHeadView.m
//  XYTest
//
//  Created by Julie on 14-8-13.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYInvoiceView.h"

@implementation XYInvoiceView

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
    //加阴影
    self.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    self.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    self.layer.shadowRadius = 4;//阴影半径，默认3
    
    //add line
    CGContextRef context = UIGraphicsGetCurrentContext();
     
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
    CGRect tableRect = self.tableview.frame;
    CGRect odpRect = self.orderTimePrompt.frame;
    CGRect odRect = self.orderTime.frame;
    CGFloat line0y = odpRect.origin.y + odpRect.size.height + (tableRect.origin.y - (odpRect.origin.y + odpRect.size.height))/2;
    CGContextMoveToPoint(context, odpRect.origin.x, line0y);
    CGContextAddLineToPoint(context, odRect.origin.x + odRect.size.width,line0y);
    
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
    CGRect pRect = self.prompt.frame;
    CGFloat line1y = tableRect.origin.y + tableRect.size.height + (pRect.origin.y - (tableRect.origin.y + tableRect.size.height))/2;
    CGContextMoveToPoint(context, pRect.origin.x, line1y);
    CGContextAddLineToPoint(context, pRect.origin.x + pRect.size.width,line1y);
    CGContextStrokePath(context);
}

@end
