//
//  XYTableViewController.m
//  BStoreMobile
//
//  Created by Jiguang on 8/1/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYTableViewController.h"
#import "XYUtil.h"

// Messages
#import "TWMessageBarManager.h"

// Numerics
CGFloat const kTWMesssageBarDemoControllerButtonPadding = 10.0f;
CGFloat const kTWMesssageBarDemoControllerButtonHeight = 50.0f;

// Colors
static UIColor *kTWMesssageBarDemoControllerButtonColor = nil;

@interface XYTableViewController ()

@end

@implementation XYTableViewController

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [XYTableViewController class])
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
    
    // delegate
    ((UIScrollView*)self.view).delegate = self;
    
    // Do any additional setup after loading the view.
    navigation = [JCRBlurView new];
    navigation.frame = CGRectMake(0, 0, 280, 46);
    navigation.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-90+((UIScrollView*)self.view).contentOffset.y);
    [navigation.layer setMasksToBounds:YES];
    navigation.layer.cornerRadius = 8.0f;
    navigation.layer.zPosition = 1000;
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
    [lbl setText:@"前方行走约10米后左转..."];
    lbl.frame = CGRectMake(91, 7, 160, 32);
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

- (void)viewDidAppear:(BOOL)animated
{
    for (id view in [self.view subviews]) {
        NSLog(@"%@", [view class]);
        for (id view2 in [view subviews]) {
            NSLog(@"\t%@", [view2 class]);
            
        }
    }
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
    
    NSLog(@"change");
}

- (void)hideNav:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"hideNav"]) {
        navigation.hidden = YES;
        [[self view] addSubview:navigation];
    }
    
    NSLog(@"change");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%f %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    navigation.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-90+scrollView.contentOffset.y);
}

@end
