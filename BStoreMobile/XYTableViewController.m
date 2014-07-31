//
//  XYTableViewController.m
//  BStoreMobile
//
//  Created by Jiguang on 8/1/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYTableViewController.h"
#import "XYUtil.h"

@interface XYTableViewController ()

@end

@implementation XYTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    navigation = [JCRBlurView new];
    navigation.frame = CGRectMake(0, 0, 280, 46);
    navigation.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-154);
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
    [btn setBackgroundImage:[UIImage imageNamed:@"up_right-50.png"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(17, 7, 32, 32);
    [navigation addSubview:btn];
    
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setText:@"左前方行走约10米..."];
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

@end
