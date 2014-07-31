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
#import "XYCameraButtons.h"

@interface XYBookOverlay : NSObject {
    
@private
    
    XYCameraButtons *btns;
    UIButton *info;
    
    UILabel *comments;
    
    UILabel *comment1;
    UILabel *comment2;
    UILabel *comment3;
    
    UIImageView *avatar1;
    UIImageView *avatar2;
    UIImageView *avatar3;
    
    UIImageView *image1;
    UIImageView *image2;
    UIImageView *image3;
    
    NSString *bookId;
    NSDictionary *bookInfoDict;
    NSArray *listComments;
    __weak UIViewController *controller;
}

@property NSString *name;
@property (weak) UIViewController *controller;

- (id)initWithId:(NSString*)key;

- (void)hide;

- (void)refresh:(UIView*)view mvp:(QCAR::Matrix44F)matrix image:(const QCAR::ImageTarget&)image;

@end
