//
//  XYAppDelegate.h
//  BStoreMobile
//
//  Created by Julie on 14-7-14.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYLocationManager.h"

@interface XYAppDelegate : UIResponder <UIApplicationDelegate, XYLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
