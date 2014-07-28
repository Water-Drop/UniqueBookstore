//
//  XYStarRatedView.h
//  BStoreMobile
//
//  Created by Julie on 14-7-29.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYStarRatedView;

@protocol StarRatedViewDelegate <NSObject>

@optional
-(void)starRatedView:(XYStarRatedView *)view score:(float)score;

@end

enum StarRatedStatus {
    RATED, SHOWED
};

@interface XYStarRatedView : UIView

- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number AtStatus:(enum StarRatedStatus)status;
- (void)changeStarForegroundViewWithPoint:(CGPoint)point;
@property (nonatomic, readonly) int numberOfStar;
@property (nonatomic, weak) id <StarRatedViewDelegate> delegate;
@property enum StarRatedStatus status;

@end
