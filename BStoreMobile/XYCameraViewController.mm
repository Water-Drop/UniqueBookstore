//
//  XYCameraViewController.m
//  BStoreMobile
//
//  Created by Jiguang on 7/18/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYCameraViewController.h"
#import <ImageIO/ImageIO.h>
#import <QCAR/QCAR.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ImageTracker.h>
#import <QCAR/Trackable.h>
#import <QCAR/DataSet.h>
#import <QCAR/CameraDevice.h>
#import "XYUtil.h"

@interface XYCameraViewController()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;

@end

@implementation XYCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [vapp stopAR:nil];
    // Be a good OpenGL ES citizen: now that QCAR is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [_viewPreview finishOpenGLESCommands];
    [_viewPreview freeOpenGLESResources];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadBeepSound];
    
    _lblStatus.hidden = YES;
    
    viewFrame =  _viewPreview.bounds;

    segmentState = 0;
    
    // If this device has a retina display, scale the view bounds that will
    // be passed to QCAR; this allows it to calculate the size and position of
    // the viewport correctly when rendering the video background
    if (YES == vapp.isRetinaDisplay) {
        viewFrame.size.width *= 2.0;
        viewFrame.size.height *= 2.0;
    }
    
    _viewPreview.controller = self;
    [_viewPreview setUpApp:vapp];
    
    // metadata output initialization
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
    
//    [self showLoadingAnimation];
    // initialize the AR session
    [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:UIInterfaceOrientationPortrait];
}

- (void)loadView
{
    [super loadView];
    
    NSLog(@"Init XYCameraViewController");
    
    vapp = [[XYCameraSession alloc] initWithDelegate:self];
    
    dataSetCurrent = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseAR)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumeAR)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self pauseAR];
    [self pauseBR];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self showLoadingAnimation];
    if (segmentState == 0) {
        [self resumeAR];
    } else {
        [self resumeBR];
    }
    [self hideLoadingAnimation];
}

#pragma Notification action

- (void) pauseAR
{
    NSError * error = nil;
    if (![vapp pauseAR:&error]) {
        NSLog(@"Error pausing AR:%@", [error description]);
    }
}

- (void) resumeAR
{
    NSError * error = nil;
    if(! [vapp resumeAR:&error]) {
        NSLog(@"Error resuming AR:%@", [error description]);
    }
    // on resume, we reset the flash and the associated menu item
    QCAR::CameraDevice::getInstance().setFlashTorchMode(false);
}

- (void) pauseBR
{
    [_videoPreviewLayer removeFromSuperlayer];
    
    [_captureSession stopRunning];
    
    [_captureSession removeOutput:_captureMetadataOutput];
}

- (void) resumeBR
{
    lastISBN = @"";
    
    lastURL = @"";
    
    [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:@"Label" waitUntilDone:NO];
    
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession addOutput:_captureMetadataOutput];
    
    [_captureSession startRunning];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [_captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,nil]];
}

#pragma Loading Animation

- (void) showLoadingAnimation {
//    CGRect mainBounds = [_viewPreview bounds];
//    CGRect indicatorBounds = CGRectMake(mainBounds.size.width / 2 - 12,
//                                        mainBounds.size.height / 2 - 12, 24, 24);
//    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:indicatorBounds];
//    
//    loadingIndicator.tag  = 1;
//    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    [_viewPreview addSubview:loadingIndicator];
//    [loadingIndicator startAnimating];
    alert = [[CustomIOS7AlertView alloc] init];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [label setText:@"正在打开摄像头"];
    [alert setContainerView:label];
    [alert setButtonTitles:[NSMutableArray arrayWithObjects:nil]];
    [alert show];
}

- (void) hideLoadingAnimation {
//    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[_viewPreview viewWithTag:1];
//    [loadingIndicator removeFromSuperview];
    [alert close];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"BookDetail"] || [segue.identifier isEqualToString:@"WebView"]) {
        UIViewController *dest = segue.destinationViewController;
        
        NSDictionary *dic = sender;
        if (dic) {
            for (NSString *key in dic) {
                NSLog(@"%@, %@", key, dic[key]);
                [dest setValue:dic[key] forKey:key];
            }
        }
    }
}

#pragma segments changed

- (IBAction)valueChanged:(id)sender {
    NSInteger index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    switch (index) {
        case 0:
            NSLog(@"Seg Control valued changed to 0");
            [self pauseBR];
            [self resumeAR];
            segmentState = 0;
            break;
        case 1:
            NSLog(@"Seg Control valued changed to 1");
            [self pauseAR];
            [self resumeBR];
            segmentState = 1;
            break;
        default:
            break;
    }
}

#pragma Helper sound

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

- (void)callWebView:(NSString*)url
{
    NSDictionary *valueDict = @{@"url": url};
    [self performSegueWithIdentifier:@"WebView" sender:valueDict];
}

- (void)callBookInfo:(NSNumber*)bookId
{
    NSLog(@"Get Book ID: %@", bookId);
    NSDictionary *valueDict = @{@"bookID": [bookId stringValue]};
    [self performSegueWithIdentifier:@"BookDetail" sender:valueDict];
}

#pragma AVCaptureMetadataOutputObjectsDelegate (For barcode reading)

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        // the barcode is QR
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            if (_audioPlayer) {
                [_audioPlayer play];
            }
            if ([lastURL isEqualToString:[metadataObj stringValue]]) {
                return;
            }
            lastURL = [metadataObj stringValue];
            
            [self performSelectorOnMainThread:@selector(callWebView:) withObject:lastURL waitUntilDone:NO];
            
        // the barcode is ISBN
        } else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            
            if (_audioPlayer) {
                [_audioPlayer play];
            }
            
            if ([lastISBN isEqualToString:[metadataObj stringValue]]) {
                return;
            }
            
//            [self showLoadingAnimation];
            
            lastISBN = [metadataObj stringValue];
            
            NSURL *url = [NSURL URLWithString:BASEURLSTRING];
            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
            manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
            NSString *path = [@"SearchBooks/ISBN/" stringByAppendingString:[metadataObj stringValue]];
            NSLog(@"path:%@",path);
            [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSArray *retArry = (NSArray *)responseObject;
                if (!retArry || retArry.count == 0) {
                    [self hideLoadingAnimation];
                    return;
                }
                NSNumber *bookId = (NSNumber*)[(NSDictionary*)[retArry objectAtIndex:0] objectForKey:@"bookID"];
                if (bookId) {
                    [self performSelectorOnMainThread:@selector(callBookInfo:) withObject:bookId waitUntilDone:NO];
                }
                NSLog(@"loadBookISBNFromServer Success");
                [self hideLoadingAnimation];
                
            }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"loadBookISBNFromServer Error:%@", error);
                [self hideLoadingAnimation];
            }];

        }
    }
}

#pragma XYCameraSessionControl

// this method is called to notify the application that the initialization (initAR) is complete
// usually the application then starts the AR through a call to startAR
- (void) onInitARDone:(NSError *)initError
{
    [self hideLoadingAnimation];
    
    if (initError == nil) {
        // If you want multiple targets being detected at once,
        // you can comment out this line
        QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 5);
        
        NSError * error = nil;
        [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];
        
    } else {
        NSLog(@"Error initializing AR:%@", [initError description]);
    }
}

// the application must initialize its tracker(s)
- (bool) doInitTrackers
{
    // Initialize the image or marker tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    
    // Image Tracker...
    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ImageTracker::getClassType());
    if (trackerBase == NULL)
    {
        NSLog(@"Failed to initialize ImageTracker.");
        return false;
    }
    NSLog(@"Successfully initialized ImageTracker.");
    return true;

}

// the application must initialize the data associated to its tracker(s)
- (bool) doLoadTrackersData
{
    dataSetCurrent = [self loadImageTrackerDataSet:@"Ister.xml"];
    
    if (! [self activateDataSet:dataSetCurrent]) {
        NSLog(@"Failed to activate dataset");
        return NO;
    }
    
    return YES;
}

// the application must starts its tracker(s)
- (bool) doStartTrackers
{
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
    if(tracker == 0) {
        return NO;
    }
    
    tracker->start();
    return YES;
}

// the application must stop its tracker(s)
- (bool) doStopTrackers
{
    // Stop the tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
    
    if (NULL != tracker) {
        tracker->stop();
        NSLog(@"INFO: successfully stopped tracker");
        return YES;
    }
    else {
        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
        return NO;
    }
}

// the application must unload the data associated its tracker(s)
- (bool) doUnloadTrackersData
{
    [self deactivateDataSet: dataSetCurrent];
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    // Destroy the data sets:
    if (!imageTracker->destroyDataSet(dataSetCurrent))
    {
        NSLog(@"Failed to destroy data set.");
    }
    
    dataSetCurrent = nil;
    
    NSLog(@"datasets destroyed");
    return YES;
}

// the application must deinititalize its tracker(s)
- (bool) doDeinitTrackers
{
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    trackerManager.deinitTracker(QCAR::ImageTracker::getClassType());
    return YES;
}

#pragma Load, active and deactive data set

// Load the image tracker data set
- (QCAR::DataSet *)loadImageTrackerDataSet:(NSString*)dataFile
{
    NSLog(@"loadImageTrackerDataSet (%@)", dataFile);
    QCAR::DataSet * dataSet = NULL;
    
    // Get the QCAR tracker manager image tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    if (NULL == imageTracker) {
        NSLog(@"ERROR: failed to get the ImageTracker from the tracker manager");
        return NULL;
    } else {
        dataSet = imageTracker->createDataSet();
        
        if (NULL != dataSet) {
            NSLog(@"INFO: successfully loaded data set");
            
            // Load the data set from the app's resources location
            if (!dataSet->load([dataFile cStringUsingEncoding:NSASCIIStringEncoding], QCAR::STORAGE_APPRESOURCE)) {
                NSLog(@"ERROR: failed to load data set");
                imageTracker->destroyDataSet(dataSet);
                dataSet = NULL;
            }
        }
        else {
            NSLog(@"ERROR: failed to create data set");
        }
    }
    
    return dataSet;
}

- (BOOL)activateDataSet:(QCAR::DataSet *)theDataSet
{
    // if we've previously recorded an activation, deactivate it
    if (dataSetCurrent != nil)
    {
        [self deactivateDataSet:dataSetCurrent];
    }
    BOOL success = NO;
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    if (imageTracker == NULL) {
        NSLog(@"Failed to load tracking data set because the ImageTracker has not been initialized.");
    }
    else
    {
        // Activate the data set:
        if (!imageTracker->activateDataSet(theDataSet))
        {
            NSLog(@"Failed to activate data set.");
        }
        else
        {
            NSLog(@"Successfully activated data set.");
            dataSetCurrent = theDataSet;
            success = YES;
        }
    }
    
    return success;
}

- (BOOL)deactivateDataSet:(QCAR::DataSet *)theDataSet
{
    if ((dataSetCurrent == nil) || (theDataSet != dataSetCurrent))
    {
        NSLog(@"Invalid request to deactivate data set.");
        return NO;
    }
    
    BOOL success = NO;
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    if (imageTracker == NULL)
    {
        NSLog(@"Failed to unload tracking data set because the ImageTracker has not been initialized.");
    }
    else
    {
        // Activate the data set:
        if (!imageTracker->deactivateDataSet(theDataSet))
        {
            NSLog(@"Failed to deactivate data set.");
        }
        else
        {
            success = YES;
        }
    }
    
    dataSetCurrent = nil;
    
    return success;
}


@end
