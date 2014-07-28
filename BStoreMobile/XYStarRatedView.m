//
//  XYStarRatedView.m
//  BStoreMobile
//
//  Created by Julie on 14-7-29.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYStarRatedView.h"

@interface XYStarRatedView()

@property (nonatomic, strong) UIView *starBackgroundView;
@property (nonatomic, strong) UIView *starForegroundView;

@end

@implementation XYStarRatedView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame numberOfStar:5 AtStatus:RATED];
}

- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number AtStatus:(enum StarRatedStatus)status
{
    self = [super initWithFrame:frame];
    self.status = status;
    if (self) {
        // self.numberOfStar vs _numberOfStar ???
        _numberOfStar = number;
        self.starBackgroundView = [self buildStarViewWithImageName:@"star_empty"];
        self.starForegroundView = [self buildStarViewWithImageName:@"star_full"];
        [self addSubview:self.starBackgroundView];
        [self addSubview:self.starForegroundView];
        [self changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    }
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.status == RATED) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        if(CGRectContainsPoint(rect,point))
        {
            [self changeStarForegroundViewWithPoint:point];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.status == RATED) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        __weak XYStarRatedView * weekSelf = self;
        
        [UIView transitionWithView:self.starForegroundView
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^
         {
             [weekSelf changeStarForegroundViewWithPoint:point];
         }
                        completion:^(BOOL finished)
         {
             
         }];
    }
}

- (UIView *)buildStarViewWithImageName:(NSString *)imageName
{
    CGRect frame = self.bounds;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    for (int i = 0; i < self.numberOfStar; i ++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        float tmp1 = 0;
        float tmp2 = 1;
        if (self.status == RATED) {
            tmp1 = 0.25;
            tmp2 = 2;
        }
        imageView.frame = CGRectMake((i+tmp1) * frame.size.width / self.numberOfStar, 0, frame.size.width / self.numberOfStar / tmp2, frame.size.height/tmp2);
        [view addSubview:imageView];
    }
    return view;
}

- (void)changeStarForegroundViewWithPoint:(CGPoint)point
{
    CGPoint p = point;
    
    if (p.x < 0)
    {
        p.x = 0;
    }
    else if (p.x > self.frame.size.width)
    {
        p.x = self.frame.size.width;
    }
    
    NSString * str = [NSString stringWithFormat:@"%0.1f",p.x / self.frame.size.width];
    float score = [str floatValue];
    // 1 为 进位单位（0.5则注释掉）
    int scoretmp = score * 10;
//    NSLog(@"%d", scoretmp);
    scoretmp = (scoretmp + 1) / 2 * 2;
    score = scoretmp / 10.0f;
//    NSLog(@"%f", score);
    // 1 为 进位单位
    p.x = score * self.frame.size.width;
    self.starForegroundView.frame = CGRectMake(0, 0, p.x, self.frame.size.height);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(starRatedView: score:)])
    {
        [self.delegate starRatedView:self score:score];
    }
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
