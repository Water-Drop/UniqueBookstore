//
//  XYOrdersPageController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-3.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYOrdersPageController.h"
#import "XYUtil.h"
#import "XYOrderPageCell.h"
#import "XYShowInvoiceController.h"

@interface XYOrdersPageController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *listOrder;
@property NSDictionary *valueDict;

@end

@implementation XYOrdersPageController

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
    [XYUtil setExtraCellLineHidden:self.tableView];
    
    [self loadOrdersFromServer];
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
    NSString *orderCellID = @"orderCellIdentifier";
    XYOrderPageCell *cell = [tableView dequeueReusableCellWithIdentifier:orderCellID];
    if (cell == nil) {
        // XYSaleItemCell.xib as NibName
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYOrderPageCell" owner:nil options:nil];
        //第一个对象就是BookInfoCellIdentifier了（xib所列子控件中的最高父控件，BookInfoCellIdentifier）
        cell = [nib objectAtIndex:0];
    }
    NSInteger index = indexPath.section;
    NSDictionary *orderInfo = self.listOrder[index];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.orderID.text = [NSString stringWithFormat:@"2014081322001832%@", orderInfo[@"orderID"]];
    cell.ostatus.text = @"已完成";
    cell.ostore.text = @"新知书店";
    cell.otime.text = orderInfo[@"date"];
    cell.ototalPrice.text = [XYUtil printMoneyAtCent:[orderInfo[@"price"] intValue]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.listOrder == nil) ? 0 : [self.listOrder count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 152.0f;
}

- (void)loadOrdersFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"User/Orderlist/" stringByAppendingString:USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.listOrder = (NSArray *)responseObject;
            NSLog(@"loadOrdersFromServer Success");
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadOrdersFromServer Error:%@", error);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *orderInfo = self.listOrder[indexPath.section];
    self.valueDict = @{@"status": [NSNumber numberWithInteger:fromOrder], @"orderID": [NSString stringWithFormat:@"%@", orderInfo[@"orderID"]]};
    [self performSegueWithIdentifier:@"showInvoice" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showInvoice"]) {
        UIViewController *dest = ((UINavigationController *)segue.destinationViewController).viewControllers[0];
        if (self.valueDict) {
            for (NSString *key in self.valueDict) {
                NSLog(@"%@, %@", key, self.valueDict[key]);
                [dest setValue:self.valueDict[key] forKey:key];
            }
        }
    }
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

@end
