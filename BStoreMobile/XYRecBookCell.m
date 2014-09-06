//
//  XYRecBookCell.m
//  BStoreMobile
//
//  Created by Julie on 14-7-17.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYRecBookCell.h"
#import "XYCollectionCell.h"

@implementation XYRecBookCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.sectionInset = UIEdgeInsetsMake(7,7,7,7);
        layout.itemSize = CGSizeMake(100, 137);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (self.yoffset > 0.0f) {
            CGRect rect = self.contentView.bounds;
            rect.origin.y += self.yoffset;
            rect.size.height -= self.yoffset;
            self.collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        } else {
            self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        }
        UINib *nib = [UINib nibWithNibName:@"XYCollectionCell" bundle:nil];
        // registerNib for custom collectioncell defined by nib
        // registerClass for UICollecitonViewCell class
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:collectionViewCellIdentifier];
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
    
    if (self.yoffset > 0.0f) {
        CGRect rect = self.contentView.bounds;
        rect.origin.y += self.yoffset;
        rect.size.height -= self.yoffset;
        self.collectionView.frame = rect;
    } else {
        self.collectionView.frame = self.contentView.bounds;
    }
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
