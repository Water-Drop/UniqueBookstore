//
//  XYThemeBookCell.h
//  BStoreMobile
//
//  Created by Julie on 14-7-31.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *themeCollectionViewCellIdentifier = @"ThemeCollectionCell";

@interface XYThemeBookCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@property CGFloat yoffset;

@end
