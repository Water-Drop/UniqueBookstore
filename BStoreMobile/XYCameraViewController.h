//
//  XYCameraViewController.h
//  BStoreMobile
//
//  Created by Jiguang on 7/18/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XYCameraSession.h"
#import "XYCameraView.h"
#import <QCAR/DataSet.h>

@interface XYCameraViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate, XYCameraSessionControl> {
    CGRect viewFrame;
    XYCameraSession * vapp;
    QCAR::DataSet*  dataSetCurrent;
}

@property (weak, nonatomic) IBOutlet XYCameraView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
- (IBAction)valueChanged:(id)sender;


@end
