//
//  XYAppDelegate.m
//  BStoreMobile
//
//  Created by Julie on 14-7-14.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYAppDelegate.h"
#import "XYLocationManager.h"
#import "XYUtil.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TWMessageBar/TWMessageBarManager.h"
#import "XYUtil.h"

@implementation XYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [XYLocationManager sharedManager].delegate = self;
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    if ([self authenticatedUser])
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    else
    {
        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"loginController"];
        
        self.window.rootViewController = rootController;
    }
    return YES;
}

- (BOOL)authenticatedUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"userList"]) {
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)performPayment
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *confrimNav = (UINavigationController *)[storyBoard instantiateViewControllerWithIdentifier:@"ConfirmNav"];
    [[self getCurrentViewController] presentViewController:confrimNav animated:YES completion:nil];

}

- (void)showNavigationModal
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *navigationNav = (UINavigationController *)[storyBoard instantiateViewControllerWithIdentifier:@"NavigationNav"];
    [[self getCurrentViewController] presentViewController:navigationNav animated:YES completion:nil];
}

- (void)showPopMsg {
    NSLog(@"Show Advertisement");
    NSString *USERID = [XYUtil getUserID];
    // check if login
    if (USERID) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"新书促销：《看见》"
                                                       description:@"柴静个人的成长告白书 中国社会十年变迁的备忘录"
                                                              type:TWMessageBarMessageTypeInfo
                                                          callback:^(void) {
                                                              [self showAdvertisement];
                                                          }];
    }
}

- (void)showAdvertisement {
    NSDictionary *valueDict = @{@"bookID": @"22"};
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *showAdsNav = (UINavigationController *)[storyBoard instantiateViewControllerWithIdentifier:@"ShowAdsNav"];
    UINavigationController *showAdsController = showAdsNav.viewControllers[0];
    if (valueDict) {
        for (NSString *key in valueDict) {
            NSLog(@"%@, %@", key, valueDict[key]);
            [showAdsController setValue:valueDict[key] forKey:key];
        }
    }
    [[self getCurrentViewController] presentViewController:showAdsNav animated:YES completion:nil];

}

- (UIViewController *)getCurrentViewController {
    UIViewController *result = nil;
    
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}

@end
