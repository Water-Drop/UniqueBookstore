//
//  XYBookOverlay.h
//  BStoreMobile
//
//  Created by Jiguang on 7/25/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QCAR/QCAR.h>
#import <QCAR/Matrices.h>
#import <QCAR/ImageTarget.h>

@interface XYBookOverlay : NSObject {
    
@private
    
    UIButton *detail;
    UIButton *navigate;
    UIButton *buy;
    NSString *name;
    __weak UIViewController *controller;
}

@property NSString *name;
@property (weak) UIViewController *controller;

- (id)initWithName:(NSString*)name;

- (void)hide;

- (void)refresh:(UIView*)view mvp:(QCAR::Matrix44F)matrix image:(const QCAR::ImageTarget&)image;

@end
