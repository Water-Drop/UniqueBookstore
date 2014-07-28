//
//  XYCameraView.h
//  BStoreMobile
//
//  Created by Jiguang on 7/24/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QCAR/UIGLViewProtocol.h>
#import "XYCameraSession.h"

@interface XYCameraView : UIView<UIGLViewProtocol> {
    
@private
    
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;

    XYCameraSession *vapp;
    
    NSMutableDictionary *overlays;
    
    __weak UIViewController *controller;

}

@property (weak) UIViewController *controller;

- (void)freeOpenGLESResources;
- (void)finishOpenGLESCommands;

- (void)setUpApp:(XYCameraSession*)app;

@end
