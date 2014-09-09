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
#import <QCAR/TargetFinder.h>
#import "XYUtil.h"

// vuforia
//static const char* const kAccessKey = "869a299f9911cd84f189d69fe8d5f79f35304372";
//static const char* const kSecretKey = "ad4a7110ad50100b22474f166d7ef4f5b3887a30";

// quanquan
static const char* const kAccessKey = "856196a1b9f162cc719f0b401132361ed7e1a7c8";
static const char* const kSecretKey = "1629ba2744350e55cca0bba82a596c131c1d9d96";

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
    
    [self showLoadingAnimation];
    
    // initialize the AR session
    [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:UIInterfaceOrientationPortrait];
    
    lastErrorCode = 99;
}

- (void)loadView
{
    [super loadView];
    
    NSLog(@"Init XYCameraViewController");
    
    vapp = [[XYCameraSession alloc]initWithDelegate:self];
    
    scanningMode = YES;
    isVisualSearchOn = NO;
    
    // single tap will trigger focus
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autofocus:)];
    
    // we use the iOS notification to pause/resume the AR when the application goes (or comeback from) background
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(pauseAR)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(resumeAR)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
    
    
    offTargetTrackingEnabled = NO;
    isShowingAnAlertView = NO;

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
    CGRect mainBounds = [_viewPreview bounds];
    CGRect indicatorBounds = CGRectMake(mainBounds.size.width / 2 - 12,
                                        mainBounds.size.height / 2 - 12, 24, 24);
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:indicatorBounds];
    
    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_viewPreview addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
}

- (void) hideLoadingAnimation {
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[_viewPreview viewWithTag:1];
    [loadingIndicator removeFromSuperview];
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
            
            [self showLoadingAnimation];
            
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
//    [self hideLoadingAnimation];
//    
//    if (initError == nil) {
//        // If you want multiple targets being detected at once,
//        // you can comment out this line
//        QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 5);
//        
//        NSError * error = nil;
//        [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];
//        
//    } else {
//        NSLog(@"Error initializing AR:%@", [initError description]);
//    }
    
    // remove loading animation
//    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
    [self hideLoadingAnimation];
    
    if (initError == nil) {
        NSError * error = nil;
        [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];
        
        // by default, we try to set the continuous auto focus mode
        // and we update menu to reflect the state of continuous auto-focus
//        bool isContinuousAutofocus = QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
//        SampleAppMenu * menu = [SampleAppMenu instance];
//        [menu setSelectionValueForCommand:C_AUTOFOCUS value:isContinuousAutofocus];
    } else {
        NSLog(@"Error initializing AR:%@", [initError description]);
    }

}

// the application must initialize its tracker(s)
- (bool) doInitTrackers
{
//    // Initialize the image or marker tracker
//    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
//    
//    // Image Tracker...
//    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ImageTracker::getClassType());
//    if (trackerBase == NULL)
//    {
//        NSLog(@"Failed to initialize ImageTracker.");
//        return false;
//    }
//    NSLog(@"Successfully initialized ImageTracker.");
//    return true;
    
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ImageTracker::getClassType());
    // Set the visual search credentials:
    QCAR::TargetFinder* targetFinder = static_cast<QCAR::ImageTracker*>(trackerBase)->getTargetFinder();
    if (targetFinder == NULL)
    {
        NSLog(@"Failed to get target finder.");
        return NO;
    }
    
    targetFinder->setUIPointColor(255, 255, 255);
    
    NSLog(@"Successfully initialized ImageTracker.");
    return YES;

}

// the application must initialize the data associated to its tracker(s)
- (bool) doLoadTrackersData
{
//    dataSetCurrent = [self loadImageTrackerDataSet:@"Ister.xml"];
//    
//    if (! [self activateDataSet:dataSetCurrent]) {
//        NSLog(@"Failed to activate dataset");
//        return NO;
//    }
//    
//    return YES;
    
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    if (imageTracker == NULL)
    {
        NSLog(@">doLoadTrackersData>Failed to load tracking data set because the ImageTracker has not been initialized.");
        return NO;
        
    }
    
    // Initialize visual search:
    QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
    if (targetFinder == NULL)
    {
        NSLog(@">doLoadTrackersData>Failed to get target finder.");
        return NO;
    }
    
    NSDate *start = [NSDate date];
    
    // Start initialization:
    if (targetFinder->startInit(kAccessKey, kSecretKey))
    {
        targetFinder->waitUntilInitFinished();
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
        
        NSLog(@"waitUntilInitFinished Execution Time: %f", executionTime);
        
        
    }
    
    int resultCode = targetFinder->getInitState();
    if ( resultCode != QCAR::TargetFinder::INIT_SUCCESS)
    {
        NSLog(@">doLoadTrackersData>Failed to initialize target finder.");
        if (resultCode == QCAR::TargetFinder::INIT_ERROR_NO_NETWORK_CONNECTION) {
            NSLog(@"CloudReco error:QCAR::TargetFinder::INIT_ERROR_NO_NETWORK_CONNECTION");
        } else if (resultCode == QCAR::TargetFinder::INIT_ERROR_SERVICE_NOT_AVAILABLE) {
            NSLog(@"CloudReco error:QCAR::TargetFinder::INIT_ERROR_SERVICE_NOT_AVAILABLE");
        } else {
            NSLog(@"CloudReco error:%d", resultCode);
        }
        
        int initErrorCode;
        if(resultCode == QCAR::TargetFinder::INIT_ERROR_NO_NETWORK_CONNECTION)
        {
            initErrorCode = QCAR::TargetFinder::UPDATE_ERROR_NO_NETWORK_CONNECTION;
        }
        else
        {
            initErrorCode = QCAR::TargetFinder::UPDATE_ERROR_SERVICE_NOT_AVAILABLE;
        }
        [self showUIAlertFromErrorCode: initErrorCode];
        return NO;
    } else {
        NSLog(@">doLoadTrackersData>target finder initialized");
    }
    
    return YES;

}

// the application must starts its tracker(s)
- (bool) doStartTrackers
{
//    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
//    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
//    if(tracker == 0) {
//        return NO;
//    }
//    
//    tracker->start();
//    return YES;
    
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(
                                                                        trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    assert(imageTracker != 0);
    imageTracker->start();
    
    // Start cloud based recognition if we are in scanning mode:
    if (scanningMode)
    {
        QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
        assert (targetFinder != 0);
        isVisualSearchOn = targetFinder->startRecognition();
    }
    return YES;

}

// the application must stop its tracker(s)
- (bool) doStopTrackers
{
//    // Stop the tracker
//    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
//    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
//    
//    if (NULL != tracker) {
//        tracker->stop();
//        NSLog(@"INFO: successfully stopped tracker");
//        return YES;
//    }
//    else {
//        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
//        return NO;
//    }
    
    // Stop the tracker
    // Stop the tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(
                                                                        trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    assert(imageTracker != 0);
    imageTracker->stop();
    
    // Stop cloud based recognition:
    QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
    assert (targetFinder != 0);
    isVisualSearchOn = !targetFinder->stop();
    return YES;

}

// the application must unload the data associated its tracker(s)
- (bool) doUnloadTrackersData
{
//    [self deactivateDataSet: dataSetCurrent];
//    
//    // Get the image tracker:
//    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
//    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
//    
//    // Destroy the data sets:
//    if (!imageTracker->destroyDataSet(dataSetCurrent))
//    {
//        NSLog(@"Failed to destroy data set.");
//    }
//    
//    dataSetCurrent = nil;
//    
//    NSLog(@"datasets destroyed");
//    return YES;
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    if (imageTracker == NULL)
    {
        NSLog(@"Failed to unload tracking data set because the ImageTracker has not been initialized.");
        return NO;
    }
    
    // Deinitialize visual search:
    QCAR::TargetFinder* finder = imageTracker->getTargetFinder();
    finder->deinit();
    return YES;

}

// the application must deinititalize its tracker(s)
- (bool) doDeinitTrackers
{
//    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
//    trackerManager.deinitTracker(QCAR::ImageTracker::getClassType());
//    return YES;
    
    return YES;
}

- (void) onQCARUpdate: (QCAR::State *) state {
    // Get the tracker manager:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    
    // Get the image tracker:
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    // Get the target finder:
    QCAR::TargetFinder* finder = imageTracker->getTargetFinder();
    
    // Check if there are new results available:
    const int statusCode = finder->updateSearchResults();
    if (statusCode < 0)
    {
        // Show a message if we encountered an error:
        NSLog(@"update search result failed:%d", statusCode);
        if (statusCode == QCAR::TargetFinder::UPDATE_ERROR_NO_NETWORK_CONNECTION) {
            [self showUIAlertFromErrorCode:statusCode];
        }
    }
    else if (statusCode == QCAR::TargetFinder::UPDATE_RESULTS_AVAILABLE)
    {
        
        // Iterate through the new results:
        for (int i = 0; i < finder->getResultCount(); ++i)
        {
            const QCAR::TargetSearchResult* result = finder->getResult(i);
            
            // Check if this target is suitable for tracking:
            if (result->getTrackingRating() > 0)
            {
                // Create a new Trackable from the result:
                QCAR::Trackable* newTrackable = (QCAR::Trackable*) finder->enableTracking(*result);
                if (newTrackable != 0)
                {
                    //  Avoid entering on ContentMode when a bad target is found
                    //  (Bad Targets are targets that are exists on the CloudReco database but not on our
                    //  own book database)
                    NSLog(@"Successfully created new trackable '%s' with rating '%d'.",
                          newTrackable->getName(), result->getTrackingRating());
                    if (offTargetTrackingEnabled) {
                        newTrackable->startExtendedTracking();
                    }
                }
                else
                {
                    NSLog(@"Failed to create new trackable.");
                }
            }
        }
    }
    
}


#pragma visual search
- (BOOL) isVisualSearchOn {
    return isVisualSearchOn;
}

- (void) setVisualSearchOn:(BOOL) isOn {
    isVisualSearchOn = isOn;
}

- (void) toggleVisualSearch {
    [self toggleVisualSearch:isVisualSearchOn];
}

- (void) toggleVisualSearch:(BOOL)visualSearchOn
{
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    assert(imageTracker != 0);
    QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
    assert (targetFinder != 0);
    if (visualSearchOn == NO)
    {
        NSLog(@"Starting target finder");
        targetFinder->startRecognition();
        isVisualSearchOn = YES;
    }
    else
    {
        NSLog(@"Stopping target finder");
        targetFinder->stop();
        isVisualSearchOn = NO;
    }
}

#pragma other

-(void)showUIAlertFromErrorCode:(int)code
{
    
    if (!isShowingAnAlertView)
    {
        if (lastErrorCode == code)
        {
            // we don't want to show twice the same error
            return;
        }
        lastErrorCode = code;
        
        NSString *title = nil;
        NSString *message = nil;
        
        if (code == QCAR::TargetFinder::UPDATE_ERROR_NO_NETWORK_CONNECTION)
        {
            title = @"Network Unavailable";
            message = @"Please check your internet connection and try again.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_REQUEST_TIMEOUT)
        {
            title = @"Request Timeout";
            message = @"The network request has timed out, please check your internet connection and try again.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_SERVICE_NOT_AVAILABLE)
        {
            title = @"Service Unavailable";
            message = @"The cloud recognition service is unavailable, please try again later.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_UPDATE_SDK)
        {
            title = @"Unsupported Version";
            message = @"The application is using an unsupported version of Vuforia.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_TIMESTAMP_OUT_OF_RANGE)
        {
            title = @"Clock Sync Error";
            message = @"Please update the date and time and try again.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_AUTHORIZATION_FAILED)
        {
            title = @"Authorization Error";
            message = @"The cloud recognition service access keys are incorrect or have expired.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_PROJECT_SUSPENDED)
        {
            title = @"Authorization Error";
            message = @"The cloud recognition service has been suspended.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_BAD_FRAME_QUALITY)
        {
            title = @"Poor Camera Image";
            message = @"The camera does not have enough detail, please try again later";
        }
        else
        {
            title = @"Unknown error";
            message = [NSString stringWithFormat:@"An unknown error has occurred (Code %d)", code];
        }
        
        //  Call the UIAlert on the main thread to avoid undesired behaviors
        dispatch_async( dispatch_get_main_queue(), ^{
            if (title && message)
            {
                UIAlertView *anAlertView = [[UIAlertView alloc] initWithTitle:title
                                                                       message:message
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                anAlertView.tag = 42;
                [anAlertView show];
                isShowingAnAlertView = YES;
            }
        });
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // we go back to the about page
    isShowingAnAlertView = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMenuDismissViewController" object:nil];
}


// enable auto-focus mode
- (void)autofocus:(UITapGestureRecognizer *)sender
{
    [self performSelector:@selector(cameraPerformAutoFocus) withObject:nil afterDelay:.4];
}

- (void)cameraPerformAutoFocus
{
    QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_TRIGGERAUTO);
}




@end
