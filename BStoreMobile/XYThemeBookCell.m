//
//  XYThemeBookCell.m
//  BStoreMobile
//
//  Created by Julie on 14-7-31.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYThemeBookCell.h"

@implementation XYThemeBookCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.sectionInset = UIEdgeInsetsMake(7,7,7,7);
        layout.itemSize = CGSizeMake(174, 92);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        UINib *nib = [UINib nibWithNibName:@"XYThemeCollectionCell" bundle:nil];
        // registerNib for custom collectioncell defined by nib
        // registerClass for UICollecitonViewCell class
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:themeCollectionViewCellIdentifier];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

// 当collection view的contentsize > content view的bound，则开始滚动
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.contentView.bounds;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
