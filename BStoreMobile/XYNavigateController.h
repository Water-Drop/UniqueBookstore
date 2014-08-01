//
//  XYNavigateController.h
//  BStoreMobile
//
//  Created by Jiguang on 7/31/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XYViewController.h"

@interface XYNavigateController : XYViewController {
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *videoPreviewLayer;
}

@property (weak, nonatomic) IBOutlet UIView *cameraView;
- (IBAction)cancelAction:(id)sender;
- (IBAction)miniAction:(id)sender;

@end
