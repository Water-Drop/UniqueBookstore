//
//  XYCameraViewController.m
//  BStoreMobile
//
//  Created by Jiguang on 7/18/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYCameraViewController.h"
#import <ImageIO/ImageIO.h>

@interface XYCameraViewController()

@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, retain) UIImage *stillImage;

- (void)startReadingBarcode;
- (void)startCapturingImage;
- (void)loadBeepSound;

@end

@implementation XYCameraViewController

@synthesize stillImage;

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
    [super viewDidLoad];
    _isReading = NO;
    
    [self loadBeepSound];
    
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [_captureStillImageOutput setOutputSettings:outputSettings];

    
    _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    // initialize capture session
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    // add video preview layer
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];

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

- (IBAction)valueChanged:(id)sender {
    NSInteger index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    switch (index) {
        case 0:
            NSLog(@"Seg Control valued changed to 0");
            [self startReadingBarcode];
            break;
        case 1:
            NSLog(@"Seg Control valued changed to 1");
            [self startCapturingImage];
            break;
        default:
            break;
    }
}

- (void)startReadingBarcode {
    
    [_captureSession addOutput:_captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [_captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,nil]];
}

- (void)startCapturingImage {
    
    [_captureSession addOutput:_captureStillImageOutput];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(doCaptureImage:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)doCaptureImage:(NSTimer *)timer {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [_captureStillImageOutput connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }

    NSLog(@"about to request a capture from: %@", _captureStillImageOutput);
	[_captureStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                          completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
                                                              CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                              if (exifAttachments) {
                                                                  NSLog(@"attachements: %@", exifAttachments);
                                                              } else {
                                                                  NSLog(@"no attachments");
                                                              }
                                                              NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                              UIImage *image = [[UIImage alloc] initWithData:imageData];
        
                                                              if (image) {
                                                                  NSLog(@"Image Captured");
                                                                  [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:@"Image Captured" waitUntilDone:NO];
                                                              }

                                                              // deal with capture image
                                                              [self setStillImage:image];
                                                              UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageCaptured" object:nil];
                                                          }
     ];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        NSLog(@"No Error");
    }
}

- (void)loadBeepSound {
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        [_audioPlayer prepareToPlay];
    }
}

#pragma AVCaptureMetadataOutputObjectsDelegate (For barcode reading)

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        // the barcode is QR
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];

            _isReading = NO;
            
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        // the barcode is ISBN
        } else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            // cast to EAN-10, for first 9 digits
            NSString *isbnBaseCodeStr = [[metadataObj stringValue] substringWithRange:NSMakeRange(3, 9)];
            
            int isbnBaseCode = [isbnBaseCodeStr intValue];
            
            // from 4 to 12
            int count = 0;
            int baseTemp = isbnBaseCode;
            for (int i = 0; i < 9; i++) {
                int digit = baseTemp % 10;
                baseTemp /= 10;
                count += digit * (i+2);
            }
            
            int isbnCode10 = isbnBaseCode * 10 + 11 - count % 11;
            
            // display
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%d", isbnCode10] waitUntilDone:NO];
            
            _isReading = NO;
            
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        }
    }
}

@end
