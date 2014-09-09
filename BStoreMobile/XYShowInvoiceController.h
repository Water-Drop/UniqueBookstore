//
//  XYShowInvoiceController.h
//  BStoreMobile
//
//  Created by Julie on 14-8-13.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

enum showInvoiceStatus {
    fromPurchase, fromOrder, fromNotPaid
};

@interface XYShowInvoiceController : UIViewController<UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property NSString *orderID;
@property enum showInvoiceStatus status;

@end
