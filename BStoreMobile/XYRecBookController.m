//
//  XYRecBookController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-17.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYRecBookController.h"
#import "XYRecBookCell.h"
#import "XYCollectionCell.h"
#import "XYUtil.h"
#import "UIImageView+AFNetworking.h"
#import "XYThemeBookCell.h"
#import "XYThemeCollectionCell.h"

#define IMAGECNT 31
#define OFFSET 15
#define OFFSET2 20

@interface XYRecBookController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property NSInteger imageIndex;

@property (nonatomic, strong) NSDictionary *valueDict;

@property (nonatomic, strong) NSDictionary *outputDict;

@end

@implementation XYRecBookController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)prepareImageArray
{
    self.imageArray = [[NSMutableArray alloc]initWithCapacity:IMAGECNT];
    for (NSInteger i = 0; i < IMAGECNT; i++) {
        NSString *filename = [NSString stringWithFormat:@"%ld", (long)i];
        filename = [filename stringByAppendingString:@"_full.JPG"];
        [self.imageArray addObject:[UIImage imageNamed:filename]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [XYUtil setExtraCellLineHidden:self.tableView];
    [self prepareImageArray];
    self.imageIndex = arc4random() % IMAGECNT;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self loadRecBookFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // fixed numOfRows
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *title = nil;
//    switch (section) {
//        case 1:
//            title = @"图书畅销榜";
//            break;
//        case 2:
//            title = @"推荐书籍";
//            break;
//        case 3:
//            title = @"分类";
//            break;
//        default:
//            break;
//    }
//    return title;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        NSString *recImageCell = @"recImageCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recImageCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recImageCell];
        }
        UIImageView *recImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 152)];
        recImageView.animationDuration = 3.0;
        recImageView.animationImages = self.imageArray;
//        [recImageView startAnimating];
//        recImageView.animationRepeatCount = 0;
//        recImageView.image = self.imageArray[self.imageIndex];
        recImageView.image = [UIImage imageNamed:@"后会无期.jpg"];
        [cell.contentView addSubview:recImageView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if (indexPath.row == 1 || indexPath.row == 2) {
        static NSString *cellIdentifier = @"RecItemCellIdentifier";
        XYRecBookCell *cell = (XYRecBookCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[XYRecBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        for (UIView *view in [cell.contentView subviews]) {
            if ([view isKindOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
        cell.yoffset = OFFSET2;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, cell.contentView.bounds.size.width, OFFSET2)];
        lbl.font = [UIFont systemFontOfSize:15.0f];
        if (indexPath.row == 1) {
            lbl.text = @"图书畅销榜";
        } else {
            lbl.text = @"为您推荐";
        }
        [cell.contentView addSubview:lbl];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if (indexPath.row == 3) {
        static NSString *cellIdentifier = @"ThemeItemCellIdentifier";
        XYThemeBookCell *cell = (XYThemeBookCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[XYThemeBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        for (UIView *view in [cell.contentView subviews]) {
            if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
        cell.yoffset = OFFSET;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 100, OFFSET)];
        lbl.font = [UIFont systemFontOfSize:15.0f];
        lbl.text = @"主要分类";
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width-80, 8, 80, OFFSET)];
        [btn setTitle:@"查看更多>" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        btn.showsTouchWhenHighlighted = NO;
        [btn addTarget:self action:@selector(clickForMore:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:lbl];
        [cell.contentView addSubview:btn];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    
    return nil;
}

// tell the delegate the table view is aobut to draw a cell for a pariticular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0 && indexPath.row != 3) {
        XYRecBookCell *newcell = (XYRecBookCell *)cell;
        [newcell setCollectionViewDataSourceDelegate:self index:(indexPath.row)];
    }
    if (indexPath.row == 3) {
        XYThemeBookCell *newcell = (XYThemeBookCell *)cell;
        [newcell setCollectionViewDataSourceDelegate:self index:(indexPath.row)];
    }
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 152.0f;
    } else if (indexPath.row < 3) {
        return 152.0f + OFFSET2;
    } else {
        return 107.0f + OFFSET;
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger fileIndex = collectionView.tag;
    NSArray *listItem;
    switch (fileIndex) {
        case 1:
            listItem = [self loadTopRated];
            break;
        case 2:
            listItem = [self loadFriends];
            break;
        case 3:
            listItem = [self loadCategory];
            break;
        default:
            break;
    }
    NSLog(@"collectionView:numberOfItemsInSection %lu", (unsigned long)[listItem count]);
    return listItem == nil ? 0 : [listItem count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag < 3) {
        // NSLog(@"collectionView:cellForItemAtIndexPath");
        XYCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYCollectionCell" owner:nil options:nil];
            //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        // configure collection view cell
        NSUInteger row = [indexPath row];
        NSInteger fileIndex = collectionView.tag;
        NSArray *listItem;
        NSString *imgKey;
        NSString *detailKey;
        NSString *nameKey;
        switch (fileIndex) {
            case 1:
                listItem = [self loadTopRated];
                nameKey = @"title";
                imgKey = @"coverimg";
                detailKey = @"author";
                break;
            case 2:
                listItem = [self loadFriends];
                nameKey = @"title";
                imgKey = @"coverimg";
                detailKey = @"author";
                break;
            default:
                break;
        }
        NSDictionary *rowDict = [listItem objectAtIndex:row];
        cell.title.text = [rowDict objectForKey:nameKey];
        // NSLog(@"cell.title.text: %@", [rowDict objectForKey:nameKey]);
        
        if (fileIndex == 3) {
            NSString *imagePath = [rowDict objectForKey:imgKey];
            imagePath = [imagePath stringByAppendingString:@".png"];
            cell.coverImage.image = [UIImage imageNamed:imagePath];
            cell.title.tag = 100;
        } else {
            NSNumber *num = [rowDict objectForKey:@"bookID"];
            cell.title.tag = [num integerValue];
            NSString *imagePath = [rowDict objectForKey:imgKey];
            __weak XYCollectionCell *weakCell = cell;
            [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakCell.coverImage.image = image;
                [weakCell setNeedsLayout];
                [weakCell setNeedsDisplay];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"Get Image from Server Error.");
            }];
        }
        
        NSString *detail = [rowDict objectForKey:detailKey];
        // NSLog(@"cell.title.text: %@", [rowDict objectForKey:detailKey]);
        cell.detail.text = detail;
        
        return cell;
    } else {
        // NSLog(@"collectionView:cellForItemAtIndexPath");
        XYThemeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:themeCollectionViewCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYThemeBookCell" owner:nil options:nil];
            //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        // configure collection view cell
        NSUInteger row = [indexPath row];
        NSArray *listItem = [self loadCategory];
        NSDictionary *rowDict = [listItem objectAtIndex:row];
        // NSLog(@"cell.title.text: %@", [rowDict objectForKey:nameKey]);
        
        NSString *imagePath = [rowDict objectForKey:@"image"];
        cell.coverImage.image = [UIImage imageNamed:imagePath];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.tag < 3) {
        XYCollectionCell * cell = (XYCollectionCell *) [collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            // 准备segue的参数传递
            self.valueDict = @{@"bookID": [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:cell.title.tag]]};
            [self performSegueWithIdentifier:@"BookDetail" sender:self];
        }
    } else {
        NSArray *listTheme = [self loadCategory];
        NSDictionary *rowDict = [listTheme objectAtIndex:indexPath.row];
        NSNumber *tagID = rowDict[@"tagID"];
        NSString *name = rowDict[@"name"];
        self.valueDict = @{@"tagID":[NSString stringWithFormat:@"%@", tagID], @"tagName":name};
        [self performSegueWithIdentifier:@"selectTheme" sender:nil];
    }
}

- (NSArray *) loadTopRated {
    //return [self loadPlistFile:@"cart" ofType:@"plist"];
    NSArray *array = nil;
    if (self.outputDict) {
        array = self.outputDict[@"toprated"];
    }
    return array;
}

- (NSArray *) loadFriends {
    //return [self loadPlistFile:@"tobuy" ofType:@"plist"];
    NSArray *array = nil;
    if (self.outputDict) {
        array = self.outputDict[@"recommend"];
    }
    return array;
}

- (NSArray *) loadCategory {
    return [self loadPlistFile:@"theme" ofType:@"plist"];
}

- (NSArray *) loadPlistFile:(NSString *)path ofType:(NSString *)type {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:path ofType:type];
    
    // 获取属性列表文件中的全部数据
    NSArray *listItem = [[NSArray alloc] initWithContentsOfFile:plistPath];
    // NSLog(@"XYRecBookController loadPlistFile from %@.%@ %lu",path, type,(unsigned long)[listItem count]);
    return listItem;
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BookDetail"] || [segue.identifier isEqualToString:@"selectTheme"]) {
        UIViewController *dest = segue.destinationViewController;
        if (self.valueDict) {
            for (NSString *key in self.valueDict) {
//                if ([dest respondsToSelector:@selector(setData:)]) {
                    NSLog(@"prepareForSegue: %@, %@", key, self.valueDict[key]);
                    [dest setValue:self.valueDict[key] forKey:key];
//                }
            }
        }
    }
}

#pragma mark - Network

- (void) loadRecBookFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"BookRecommendV2/" stringByAppendingString:USERID];
        NSLog(@"path:%@", path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.outputDict = (NSDictionary *)responseObject;
            NSLog(@"loadRecBookFromServer Success");
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadRecBookFromServer Error:%@", error);
        }];
    }
}

- (IBAction)clickForMore:(id)sender
{
    NSLog(@"click For More...");
    [self performSegueWithIdentifier:@"allTheme" sender:nil];
}

@end
