//
//  XYWebViewController.h
//  BStoreMobile
//
//  Created by Jiguang on 7/31/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYWebViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property NSString *url;

@end
