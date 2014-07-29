//
//  XYAutoLayoutLabel.m
//  BStoreMobile
//
//  Created by Julie on 14-7-29.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYAutoLayoutLabel.h"

#define MIN_HEIGHT 30.0f

@implementation XYAutoLayoutLabel

@synthesize minHeight;

- (id)init {
    if ([super init]) {
        self.minHeight = minHeight;
    }
    return self;
}

- (void)calculateSize
{
    CGSize constraint = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
    
    NSDictionary *attribute = @{NSFontAttributeName : self.font};
    
    CGSize size = [self.text boundingRectWithSize:constraint options:\
                   NSStringDrawingTruncatesLastVisibleLine |
                   NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    [self setLineBreakMode:NSLineBreakByTruncatingTail];
    [self setAdjustsFontSizeToFitWidth:NO];
    [self setNumberOfLines:0];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, MAX(size.height, MIN_HEIGHT))];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    [self calculateSize];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    
    [self calculateSize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
