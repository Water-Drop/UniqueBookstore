//
//  XYBookOverlay.m
//  BStoreMobile
//
//  Created by Jiguang on 7/25/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYBookOverlay.h"

@implementation XYBookOverlay

@synthesize name;
@synthesize controller;

- (id)initWithName:(NSString*)key
{
    self = [super init];
    
    name = key;
    
    return self;
}

- (void)hide
{
    if (detail != nil) {
        detail.hidden = YES;
    }
    
    if (navigate != nil) {
        navigate.hidden = YES;
    }
    
    if (buy != nil) {
        buy.hidden = YES;
    }
}

- (void)refresh:(UIView*)view mvp:(QCAR::Matrix44F)matrix image:(const QCAR::ImageTarget&)image
{

    if (detail == nil) {
        detail = [[UIButton alloc] init];
        [detail addTarget:self action:@selector(detailAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    detail.hidden = NO;
    
    float x = matrix.data[12]/matrix.data[15];
    
    float y = matrix.data[13]/matrix.data[15];
    
    float w = [view bounds].size.width;
    
    float h = [view bounds].size.height;
    
    CGRect bound = CGRectMake(w/2*(x+1)-34.5, h-h/2*(y+1)-14.5, 69, 29);
    
    detail.frame = bound;
    
    [detail setTitle:name forState:UIControlStateNormal];
    [detail setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    detail.layer.borderWidth = 1.0f;
    detail.layer.cornerRadius = 5.0f;
    detail.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    detail.layer.masksToBounds = YES;
    detail.layer.backgroundColor = [UIColor whiteColor].CGColor;
    detail.layer.opacity = 0.75f;
    
    [view addSubview:detail];
    [view bringSubviewToFront:detail];

}

- (void)detailAction
{
    NSDictionary *dic = @{@"titleStr": @"A1-南非", @"detailStr": @"南非，南非"};
    [controller performSegueWithIdentifier:@"BookDetail" sender:dic];
}

@end
