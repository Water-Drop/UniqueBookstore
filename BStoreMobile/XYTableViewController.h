//
//  XYTableViewController.h
//  BStoreMobile
//
//  Created by Jiguang on 8/1/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYLocationManager.h"
#import "JCRBlurView.h"

@interface XYTableViewController : UITableViewController<UIScrollViewDelegate, UITableViewDelegate> {

    JCRBlurView *navigation;
}

@end