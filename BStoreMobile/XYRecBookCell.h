//
//  XYRecBookCell.h
//  BStoreMobile
//
//  Created by Julie on 14-7-17.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *collectionViewCellIdentifier = @"CollectionCell";

@interface XYRecBookCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
