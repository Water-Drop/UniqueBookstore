//
//  XYPurchaseController.h
//  BStoreMobile
//
//  Created by Julie on 14-7-30.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYTableViewController.h"

enum purchaseStatus {
    FROMCART, FROMNOTPAID
};

@interface XYPurchaseController : XYTableViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@end
