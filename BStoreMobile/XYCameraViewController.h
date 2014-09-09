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
#import "XYViewController.h"
#import "CustomIOS7AlertView.h"

@interface XYCameraViewController : XYViewController<AVCaptureMetadataOutputObjectsDelegate, XYCameraSessionControl> {
    CGRect viewFrame;
    XYCameraSession * vapp;
    QCAR::DataSet*  dataSetCurrent;
    NSString* lastISBN;
    NSString* lastURL;
    int segmentState;
    CustomIOS7AlertView* alert;
}

@property (weak, nonatomic) IBOutlet XYCameraView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
- (IBAction)valueChanged:(id)sender;


@end
