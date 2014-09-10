//
//  XYFriendsInfoController.h
//  BStoreMobile
//
//  Created by Julie on 14-7-30.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYTableViewController.h"

enum friendsInfoStatus {
    DELETE, ADD, INFO
};

@interface XYFriendsInfoController : XYTableViewController<UIAlertViewDelegate>

@property (nonatomic, strong) NSString *uname;
@property (nonatomic, strong) NSString *gen;
@property (nonatomic, strong) NSString *addr;
@property (nonatomic, strong) NSString *sg;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSNumber *head;
@property (nonatomic, strong) NSString *nickname;
@property enum friendsInfoStatus status;

@end
