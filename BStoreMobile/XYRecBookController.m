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

@interface XYRecBookController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setExtraCellLineHidden:self.tableView];
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
            title = @"分类";
            break;
        default:
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RecItemCellIdentifier";
    XYRecBookCell *cell = (XYRecBookCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[XYRecBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

// tell the delegate the table view is aobut to draw a cell for a pariticular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(XYRecBookCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:(indexPath.section-1)];
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 152;
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger fileIndex = collectionView.tag;
    NSArray *listItem;
    switch (fileIndex) {
        case 0:
            listItem = [self loadTopRated];
            break;
        case 1:
            listItem = [self loadFriends];
            break;
        case 2:
            listItem = [self loadCategory];
            break;
        default:
            break;
    }
    NSLog(@"collectionView:numberOfItemsInSection %lu", (unsigned long)[listItem count]);
    return [listItem count];
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
    switch (fileIndex) {
        case 0:
            listItem = [self loadTopRated];
            break;
        case 1:
            listItem = [self loadFriends];
            break;
        case 2:
            listItem = [self loadCategory];
            break;
        default:
            break;
    }
    NSDictionary *rowDict = [listItem objectAtIndex:row];
    cell.title.text = [rowDict objectForKey:@"name"];
    NSLog(@"cell.title.text: %@", [rowDict objectForKey:@"name"]);
    
    NSString *imagePath = [rowDict objectForKey:@"image"];
    imagePath = [imagePath stringByAppendingString:@".png"];
    cell.coverImage.image = [UIImage imageNamed:imagePath];
    
    NSString *detail = [rowDict objectForKey:@"detail"];
    NSLog(@"cell.title.text: %@", [rowDict objectForKey:@"detail"]);
    cell.detail.text = detail;
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end
