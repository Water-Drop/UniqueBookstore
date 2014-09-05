//
//  XYOrderPageCell.h
//  BStoreMobile
//
//  Created by Julie on 14-9-5.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYOrderPageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderID;
@property (weak, nonatomic) IBOutlet UILabel *ostatus;
@property (weak, nonatomic) IBOutlet UILabel *ostore;
@property (weak, nonatomic) IBOutlet UILabel *otime;
@property (weak, nonatomic) IBOutlet UILabel *ototalPrice;

@end
