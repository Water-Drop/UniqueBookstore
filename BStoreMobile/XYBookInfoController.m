//
//  XYBookInfoController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-17.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYBookInfoController.h"
#import "XYBookInfoMainCell.h"

@interface XYBookInfoController ()

enum BookInfoStatus {
    DETAILS, COMMENTS, RECOMMENDS
};

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property enum BookInfoStatus status;
@property (nonatomic, strong) UIView *toolView;
@property NSString *imageStr;
@property NSString *priceStr;

@end

@implementation XYBookInfoController

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
    [self prepareForToolView];
    [self getInfoFromSegue];
}

- (void)getInfoFromSegue
{
    NSArray *array = [NSArray arrayWithObjects:@"cart",@"tobuy",@"paid", nil];
    for (NSInteger i=0; i<[array count]; i++) {
        NSArray *listItem = [self loadPlistFile:array[i] ofType:@"plist"];
        for (NSInteger j=0; j<[listItem count]; j++) {
            NSDictionary *rowDict = listItem[j];
            if ([[rowDict objectForKey:@"name"] isEqualToString:self.titleStr]) {
                self.imageStr = [rowDict objectForKey:@"image"];
                self.priceStr = @"￥";
                self.priceStr = [self.priceStr stringByAppendingString:[rowDict objectForKey:@"price"]];
                break;
            }
        }
    }
    NSLog(@"getInfoFromSegue at XYBookInfoController");
}

// add ToolView with SegControl in section#1's header
- (void)prepareForToolView
{
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    NSArray *segItemsArray = [NSArray arrayWithObjects: @"详细信息", @"读者评论", @"相关推荐", nil];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    segControl.frame = CGRectMake(16, 8, 287, 29);
    segControl.selectedSegmentIndex = 0;
    self.status = DETAILS;
    [segControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.toolView addSubview:segControl];
    self.toolView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *mainCellID = @"BookInfoCellIdentifier";
        XYBookInfoMainCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellID];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYBookInfoMainCell" owner:nil options:nil];
            //第一个对象就是BookInfoCellIdentifier了（xib所列子控件中的最高父控件，BookInfoCellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        
        
//        cell.title.text = @"BI1-USA";
//        cell.detail.text = @"克林顿，布什，奥巴马";
//        cell.coverImage.image = [UIImage imageNamed:@"USA.png"];
//        [cell.buyButton setTitle:@"￥234.56" forState: UIControlStateNormal];
        
        cell.title.text = self.titleStr;
        cell.detail.text = self.detailStr;
        cell.coverImage.image = [UIImage imageNamed:self.imageStr];
        [cell.buyButton setTitle:self.priceStr forState:UIControlStateNormal];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    NSString *detailCellID = @"BookDetailCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailCellID];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 143.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 45.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        // 每次reload tableview时，均要调用，因此不能在此处alloc/init toolbar，应当将toolbar作为一个成员变量，只初始化一次
        return self.toolView;
    }
    return nil;
}

- (IBAction)valueChanged:(id)sender
{
    NSInteger index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    switch (index) {
        case 0:
            NSLog(@"Seg Control valued changed to 0");
            self.status = DETAILS;
            break;
        case 1:
            NSLog(@"Seg Control valued changed to 1");
            self.status = COMMENTS;
            break;
        case 2:
            NSLog(@"Seg Control valued changed to 2");
            self.status = RECOMMENDS;
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (NSArray *) loadPlistFile:(NSString *)path ofType:(NSString *)type {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:path ofType:type];
    
    // 获取属性列表文件中的全部数据
    NSArray *listItem = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSLog(@"XYBookInfoController loadPlistFile from %@.%@ %lu",path, type,(unsigned long)[listItem count]);
    return listItem;
}

@end
