//
//  XYCameraButtons.h
//  BStoreMobile
//
//  Created by Jiguang on 7/29/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYCameraButtons : UIView

@property (weak, nonatomic) IBOutlet UIButton *cartButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *price;

- (void)focus;
- (void)normal;

@end
