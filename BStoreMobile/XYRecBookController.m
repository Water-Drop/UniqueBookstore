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

#define IMAGECNT 31

@interface XYRecBookController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property NSInteger imageIndex;

@property (nonatomic, strong) NSDictionary *valueDict;

@property (nonatomic, strong) NSDictionary *outputDict;

@end

@implementation XYRecBookController

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

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
    [self setExtraCellLineHidden:self.tableView];
    [self prepareImageArray];
    self.imageIndex = arc4random() % IMAGECNT;
    self.outputDict = [XYUtil parseRecBookInfo];
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
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 1:
            title = @"图书畅销榜";
            break;
        case 2:
            title = @"大家都在看";
            break;
        case 3:
            title = @"推荐主题";
            break;
        default:
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
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
        recImageView.image = self.imageArray[self.imageIndex];
        [cell.contentView addSubview:recImageView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    static NSString *cellIdentifier = @"RecItemCellIdentifier";
    XYRecBookCell *cell = (XYRecBookCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[XYRecBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

// tell the delegate the table view is aobut to draw a cell for a pariticular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(XYRecBookCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        [cell setCollectionViewDataSourceDelegate:self index:(indexPath.section)];
    }
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 152.0f;
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger fileIndex = collectionView.tag;
    NSArray *listItem;
    switch (fileIndex) {
        case 1:
            // listItem = [self loadTopRated];
            listItem = [self.outputDict objectForKey:@"toprated"];
            break;
        case 2:
            // listItem = [self loadFriends];
            listItem = [self.outputDict objectForKey:@"recommend"];
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
    NSLog(@"collectionView:cellForItemAtIndexPath");
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
            // listItem = [self loadTopRated];
            listItem = [self.outputDict objectForKey:@"toprated"];
            nameKey = @"title";
            imgKey = @"coverimg";
            detailKey = @"author";
            break;
        case 2:
            // listItem = [self loadFriends];
            listItem = [self.outputDict objectForKey:@"recommend"];
            nameKey = @"title";
            imgKey = @"coverimg";
            detailKey = @"author";
            break;
        case 3:
            listItem = [self loadCategory];
            nameKey = @"name";
            imgKey = @"image";
            detailKey = @"detail";
            break;
        default:
            break;
    }
    NSDictionary *rowDict = [listItem objectAtIndex:row];
    cell.title.text = [rowDict objectForKey:nameKey];
    NSLog(@"cell.title.text: %@", [rowDict objectForKey:nameKey]);
    
    NSString *imagePath = [rowDict objectForKey:imgKey];
    imagePath = [imagePath stringByAppendingString:@".png"];
    cell.coverImage.image = [UIImage imageNamed:imagePath];
    
    NSString *detail = [rowDict objectForKey:detailKey];
    NSLog(@"cell.title.text: %@", [rowDict objectForKey:detailKey]);
    cell.detail.text = detail;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag <= 3) {
        XYCollectionCell * cell = (XYCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            // 准备segue的参数传递
            self.valueDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"titleStr",cell.title.text,
                              @"detailStr",cell.detail.text,
                              nil];
            [self performSegueWithIdentifier:@"BookDetail" sender:self];
        }
    }
}

- (NSArray *) loadTopRated {
    return [self loadPlistFile:@"cart" ofType:@"plist"];
}

- (NSArray *) loadFriends {
    return [self loadPlistFile:@"tobuy" ofType:@"plist"];
}

- (NSArray *) loadCategory {
    return [self loadPlistFile:@"paid" ofType:@"plist"];
}

- (NSArray *) loadPlistFile:(NSString *)path ofType:(NSString *)type {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:path ofType:type];
    
    // 获取属性列表文件中的全部数据
    NSArray *listItem = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSLog(@"XYRecBookController loadPlistFile from %@.%@ %lu",path, type,(unsigned long)[listItem count]);
    return listItem;
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BookDetail"]) {
        UIViewController *dest = segue.destinationViewController;
        if (self.valueDict) {
            for (NSString *key in self.valueDict) {
//                if ([dest respondsToSelector:@selector(setData:)]) {
                    NSLog(@"%@, %@", key, self.valueDict[key]);
                    [dest setValue:key forKey:self.valueDict[key]];
//                }
            }
        }
    }
}

@end
