//
//  XYBaseViewController.m
//  BStoreMobile
//
//  Created by Jiguang on 8/1/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYViewController.h"

// Messages
#import "TWMessageBarManager.h"

// Numerics
CGFloat const kTWMesssageBarDemoControllerButtonPadding = 10.0f;
CGFloat const kTWMesssageBarDemoControllerButtonHeight = 50.0f;

// Colors
static UIColor *kTWMesssageBarDemoControllerButtonColor = nil;

@interface XYViewController ()

@end

@implementation XYViewController

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [XYViewController class])
	{
        kTWMesssageBarDemoControllerButtonColor = [UIColor colorWithWhite:0.0 alpha:0.25];
	}
}

- (id)initWithStyleSheet:(NSObject<TWMessageBarStyleSheet> *)stylesheet
{
    self = [super init];
    if (self)
    {
        [TWMessageBarManager sharedInstance].styleSheet = stylesheet;
    }
    return self;
}

- (id)init
{
    return [self initWithStyleSheet:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    navigation = [JCRBlurView new];
    navigation.frame = CGRectMake(0, 0, 280, 46);
    navigation.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-90);
    [navigation.layer setMasksToBounds:YES];
    navigation.layer.cornerRadius = 8.0f;
    navigation.hidden = ![XYLocationManager sharedManager].showNavigation;
    [[self view] addSubview:navigation];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showModal)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [navigation addGestureRecognizer:tapGesture];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setBackgroundImage:[UIImage imageNamed:@"arrow_m.png"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(17, 7, 32, 32);
    [navigation addSubview:btn];
    
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setText:@"前方行走约10米后左转"];
    lbl.frame = CGRectMake(62, 7, 210, 32);
    [lbl setTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [navigation addSubview:lbl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNav:)
                                                 name:@"showNav"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideNav:)
                                                 name:@"hideNav"
                                               object:nil];
}

- (void)showModal
{
    [[XYLocationManager sharedManager] showNavigationModal];
}

- (void)showNav:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"showNav"]) {
        navigation.hidden = NO;
        [[self view] addSubview:navigation];
    }
}

- (void)hideNav:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"hideNav"]) {
        navigation.hidden = YES;
        [[self view] addSubview:navigation];
    }
}

@end
