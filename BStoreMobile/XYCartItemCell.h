//
//  XYCartItemCell.h
//  BStoreMobile
//
//  Created by Julie on 14-7-24.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYCartItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (weak, nonatomic) IBOutlet UITextField *cntText;
@property (weak, nonatomic) IBOutlet UIButton *tobuyBtn;

@end
