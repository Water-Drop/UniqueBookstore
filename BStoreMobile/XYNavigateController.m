//
//  XYNavigateController.m
//  BStoreMobile
//
//  Created by Jiguang on 7/31/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYNavigateController.h"
#import "XYLocationManager.h"
#import "XYUtil.h"

@interface XYNavigateController ()

@end

@implementation XYNavigateController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [XYLocationManager sharedManager].showNavigation = YES;
    
    NSLog(@"Navigate to book %d", [XYLocationManager sharedManager].navigateBook);
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // initialize capture session
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession addInput:input];
    
    // add video preview layer
    
    videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoPreviewLayer setFrame:_cameraView.layer.bounds];
    
    [_cameraView.layer addSublayer:videoPreviewLayer];
    
    [captureSession startRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelAction:(id)sender {
    [XYLocationManager sharedManager].showNavigation = NO;
    [XYLocationManager sharedManager].navigateBook = -1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideNav"
                                                        object:self];
    [captureSession stopRunning];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)miniAction:(id)sender {
    [XYLocationManager sharedManager].showNavigation = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNav"
                                                        object:self];
    [captureSession stopRunning];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
