//
//  XYBaseViewController.h
//  BStoreMobile
//
//  Created by Jiguang on 8/1/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYLocationManager.h"
#import "JCRBlurView.h"
#import "TWMessageBarManager.h"

@interface XYViewController : UIViewController {
    
    JCRBlurView *navigation;
}
- (id)initWithStyleSheet:(NSObject<TWMessageBarStyleSheet> *)stylesheet;

@end
