//
//  XYFriendsInfoController.h
//  BStoreMobile
//
//  Created by Julie on 14-7-30.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

enum friendsInfoStatus {
    DELETE, ADD
};

@interface XYFriendsInfoController : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, strong) NSString *uname;
@property (nonatomic, strong) NSString *gen;
@property (nonatomic, strong) NSString *addr;
@property (nonatomic, strong) NSString *sg;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSNumber *head;
@property enum friendsInfoStatus status;

@end
