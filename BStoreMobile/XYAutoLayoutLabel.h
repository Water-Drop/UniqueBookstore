//
//  XYAutoLayoutLabel.h
//  BStoreMobile
//
//  Created by Julie on 14-7-29.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYAutoLayoutLabel : UILabel

@property (nonatomic) double minHeight;

- (void)calculateSize;

@end
