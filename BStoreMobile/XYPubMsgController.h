//
//  XYPubMsgController.h
//  BStoreMobile
//
//  Created by Julie on 14-7-21.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYViewController.h"
#import "TITokenField.h"

@interface XYPubMsgController : XYViewController<UIAlertViewDelegate,TITokenFieldDelegate, UITextViewDelegate>

@property NSString *selectItem;
@property NSNumber *selectID;

@end
