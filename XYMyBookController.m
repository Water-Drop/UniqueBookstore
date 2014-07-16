//
//  MyBookController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-14.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYMyBookController.h"
#import "XYSaleItemCell.h"

@interface XYMyBookController ()

@property (nonatomic, strong) NSArray *listCart;

- (IBAction)valueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XYMyBookController

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
    [self loadCart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.listCart count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    
    /* // 不在/在sb中的tableview里添加prototype，从storyboard创建
    static NSString *CellIdentifier = @"CellIdentifier";
    XYSaleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[XYSaleItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    */
    
    // 从xib中创建，不在sb中的tableview里添加prototype(否则关联的outlet是nil，没有初始化，main interface是sb)
    static NSString *CellIdentifier = @"CellIdentifier";
    XYSaleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // XYSaleItemCell.xib as NibName
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYSaleItemCell" owner:nil options:nil];
        //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
        cell = [nib objectAtIndex:0];
    }
    if (cell == nil) {
        NSLog(@"NILLLLL");
    }
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    NSDictionary *rowDict = [self.listCart objectAtIndex:row];
    cell.title.text = [rowDict objectForKey:@"name"];
    
    NSString *imagePath = [rowDict objectForKey:@"image"];
    imagePath = [imagePath stringByAppendingString:@".png"];
    cell.coverImage.image = [UIImage imageNamed:imagePath];
    
    NSString *detail = [rowDict objectForKey:@"detail"];
    cell.detail.text = detail;
    
    NSString *price = @"￥";
    price = [price stringByAppendingString:[rowDict objectForKey:@"price"]];
    [cell.buyButton setTitle:price forState: UIControlStateNormal];
    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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

- (IBAction)valueChanged:(id)sender {
    NSInteger index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    switch (index) {
        case 0:
            NSLog(@"Seg Control valued changed to 0");
            [self loadCart];
            break;
        case 1:
            NSLog(@"Seg Control valued changed to 1");
            [self loadToBuy];
            break;
        case 2:
            NSLog(@"Seg Control valued changed to 2");
            [self loadPaid];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (void) loadCart {
    [self loadPlistFile:@"cart" ofType:@"plist"];
}

- (void) loadToBuy {
    [self loadPlistFile:@"tobuy" ofType:@"plist"];
}

- (void) loadPaid {
    [self loadPlistFile:@"paid" ofType:@"plist"];
}

- (void) loadPlistFile:(NSString *)path ofType:(NSString *)type {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:path ofType:type];
    
    // 获取属性列表文件中的全部数据
    self.listCart = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSLog(@"loadPlistFile from %@.%@ %d",path, type,[self.listCart count]);
}
@end
