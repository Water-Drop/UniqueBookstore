//
//  XYShowInvoiceController.m
//  BStoreMobile
//
//  Created by Julie on 14-8-13.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYShowInvoiceController.h"
#import "XYInvoiceView.h"
#import "XYUtil.h"
#import "XYRecBookCell.h"
#import "XYCollectionCell.h"
#import "UIKit+AFNetworking.h"

@interface XYShowInvoiceController ()
- (IBAction)doneAction:(id)sender;
@property NSDictionary *orderInfo;
@property NSMutableArray *listAlready;
@property NSMutableArray *listToCarry;
@property XYInvoiceView *invoice;
@property NSInteger totCnt;
@property int totPrice;

@end

@implementation XYShowInvoiceController

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
    
    self.invoice = [[NSBundle mainBundle] loadNibNamed:@"XYInvoiceView" owner:nil options:nil][0];
    CGRect rect = self.invoice.bounds;
    rect.origin.x = 10;
    rect.origin.y = 78;
    [self.invoice setFrame:rect];
    self.invoice.tableview.delegate = self;
    self.invoice.tableview.dataSource = self;
    [self.view addSubview:self.invoice];
    
    [self loadOrderDetailFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *orderCellID = @"orderCellID";
    XYRecBookCell *cell = (XYRecBookCell *)[tableView dequeueReusableCellWithIdentifier:orderCellID];
    if (cell == nil) {
        cell = [[XYRecBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderCellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 152.0f;
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

- (IBAction)doneAction:(id)sender {
    if (self.status == fromPurchase) {
        UINavigationController *nav1 = (UINavigationController *)self.presentingViewController;
        UITabBarController *tab = (UITabBarController *)nav1.presentingViewController;
        UINavigationController *nav2 = (UINavigationController *)tab.selectedViewController;
        NSLog(@"nav1: %@",NSStringFromClass([nav1.viewControllers[0] class]));
        NSLog(@"nav2: %@", NSStringFromClass([nav2.viewControllers[0] class]));
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^(void) {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    } else if (self.status == fromOrder) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void) loadOrderDetailFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"User/OrderDetail/" stringByAppendingString:self.orderID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.orderInfo = (NSDictionary *)responseObject;
        [self calculateList];
        NSLog(@"loadOrderDetailFromServer Success");
        [self reloadView];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadOrderDetailFromServer Error:%@", error);
    }];
}

- (void) calculateList
{
    if (self.orderInfo && self.orderInfo[@"orderdetails"]) {
        NSArray *listPaid = [self.orderInfo objectForKey:@"orderdetails"];
        self.listAlready = [[NSMutableArray alloc] init];
        self.listToCarry = [[NSMutableArray alloc] init];
        self.totCnt = 0;
        self.totPrice = 0;
        for (NSDictionary *rowDict in listPaid) {
            self.totCnt += [rowDict[@"amount"] integerValue];
            int amount = [rowDict[@"amount"] intValue];
            int price = [rowDict[@"price"] intValue];
            self.totPrice += amount * price;
            if ([rowDict[@"status"] intValue] == 0) {
                [self.listToCarry addObject:rowDict];
            } else if ([rowDict[@"status"] intValue] == 1) {
                [self.listAlready addObject:rowDict];
            }
        }
    }
}

// tell the delegate the table view is aobut to draw a cell for a pariticular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(XYRecBookCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [cell setCollectionViewDataSourceDelegate:self index:(indexPath.section)];
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.orderInfo) {
        NSArray *listPaid = [self.orderInfo objectForKey:@"orderdetails"];
        return listPaid == nil ? 0 : [listPaid count];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
    NSUInteger listToCarryCnt = (self.listToCarry == nil) ? 0 : [self.listToCarry count];
//    NSUInteger listAlreadyCnt = (self.listAlready == nil) ? 0 : [self.listAlready count];
    NSArray *list = (row >= listToCarryCnt) ? self.listAlready : self.listToCarry;
    NSUInteger idx = (row >= listToCarryCnt) ? (row - listToCarryCnt) : row;
    NSString *imgKey = @"coverimg";
    NSString *nameKey = @"title";
    NSDictionary *rowDict = [list objectAtIndex:idx];
    cell.title.text = [rowDict objectForKey:nameKey];
    // NSLog(@"cell.title.text: %@", [rowDict objectForKey:nameKey]);
    
    int amount = [rowDict[@"amount"] intValue];
    NSString *amountStr = [NSString stringWithFormat:@"%d", amount];
    int eachPriceAtCent = [rowDict[@"price"] intValue];
    NSString *eachPrice = [XYUtil printMoneyAtCent:eachPriceAtCent];
    
    cell.detail.text = [NSString stringWithFormat:@"%@ × %@", eachPrice, amountStr];
    if (row < listToCarryCnt) {
        cell.detail.textColor = [UIColor redColor];
    }
    
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
    
    return cell;
}

- (void)reloadView
{
    if (self.orderInfo) {
        self.invoice.orderTime.text = self.orderInfo[@"date"];
        self.invoice.totCnt.text = [NSString stringWithFormat:@"%@本", [NSNumber numberWithInteger:self.totCnt]];
        self.invoice.totPrice.text = [XYUtil printMoneyAtCent:self.totPrice];
        self.invoice.orderID.text = [NSString stringWithFormat:@"2014081322001832%@", self.orderInfo[@"orderID"]];
        
        self.invoice.bookStore.text = @"新知书店";
        self.invoice.status.text = @"已完成";
    }
    [self.invoice.tableview reloadData];
}

@end
