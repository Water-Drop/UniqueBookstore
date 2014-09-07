//
//  XYShowAdsController.h
//  BStoreMobile
//
//  Created by Julie on 14-9-7.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYStarRatedView.h"
#import "XYViewController.h"

@interface XYShowAdsController : XYViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, StarRatedViewDelegate>

@property NSString *titleStr;
@property NSString *detailStr;
@property NSString *bookID;

@end
