//
//  XYPurchaseController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-30.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYPurchaseController.h"
#import "XYRecBookController.h"
#import "XYRecBookCell.h"
#import "XYCollectionCell.h"
#import "XYUtil.h"
#import "UIImageView+AFNetworking.h"
#import "XYShowInvoiceController.h"

@interface XYPurchaseController ()

@property (nonatomic,strong) NSMutableArray *listCart; // getFromServer or byPassParam
@property (nonatomic,strong) NSString *totalPriceStr; // calculate or byPassParam
- (IBAction)purchaseAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@property enum purchaseStatus status;
@property (nonatomic,strong) NSNumber *statusNum; // byPassParam
@property NSDictionary *valueDict;

@end

@implementation XYPurchaseController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.status = [self.statusNum intValue];
    if (self.status == FROMCART) {
        [self loadCartFromServer];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network
-(void) loadCartFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"User/MyCart/" stringByAppendingString:USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *tmp = (NSArray *)responseObject;
            if (tmp) {
                self.listCart = [[NSMutableArray alloc]initWithArray:tmp];
                [self calculateTotalPrice];
            }
            NSLog(@"loadCartFromServer Success");
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadCartFromServer Error:%@", error);
        }];
    }
}

// tell the delegate the table view is aobut to draw a cell for a pariticular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(XYRecBookCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        [cell setCollectionViewDataSourceDelegate:self index:(indexPath.section)];
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listCart == nil ? 0 : [self.listCart count];
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
    NSString *imgKey = @"coverimg";
    NSString *nameKey = @"title";
    NSDictionary *rowDict = [self.listCart objectAtIndex:row];
    cell.title.text = [rowDict objectForKey:nameKey];
    // NSLog(@"cell.title.text: %@", [rowDict objectForKey:nameKey]);
    
    int amount = [rowDict[@"amount"] intValue];
    NSString *amountStr = [NSString stringWithFormat:@"%d", amount];
    int eachPriceAtCent = [rowDict[@"price"] intValue];
    NSString *eachPrice = [XYUtil printMoneyAtCent:eachPriceAtCent];
    
    cell.detail.text = [NSString stringWithFormat:@"%@ × %@", eachPrice, amountStr];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"PurchaseCellIdentifier";
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            for (UIView *view in [cell.contentView subviews]) {
                if ([view isKindOfClass:[UILabel class]]) {
                    [view removeFromSuperview];
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lbl0 = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, 78, 21)];
            lbl0.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            lbl0.text = @"应付金额";
            UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(111, 11, 189, 21)];
            lbl1.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            lbl1.text = [NSString stringWithFormat:@"%@", self.totalPriceStr];
            lbl1.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:lbl0];
            [cell.contentView addSubview:lbl1];
            return cell;
        } else {
            NSString *cellID = @"PurchaseListItemID";
            XYRecBookCell *cell = (XYRecBookCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[XYRecBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"余额支付";
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.textLabel.text = @"其他支付";
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        return 152.0f;
    } else {
        return 44.0f;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"订单信息";
    } else if (section == 1) {
        return @"支付方式";
    }
    return nil;
}

- (void)calculateTotalPrice
{
    if (self.listCart && [self.listCart count] > 0) {
        int allAtCent = 0;
        for (NSDictionary *rowDict in self.listCart) {
            int amount = [rowDict[@"amount"] intValue];
            int eachPriceAtCent = [rowDict[@"price"] intValue];
            int totPriceAtCent = eachPriceAtCent * amount;
            allAtCent += totPriceAtCent;
        }
        self.totalPriceStr = [XYUtil printMoneyAtCent:allAtCent];
    } else {
        self.totalPriceStr = @"";
    }
}

- (IBAction)purchaseAction:(id)sender
{
    if (self.status == FROMCART) {
        [self purchaseToServerByRemaining];
    } else {
        [self purchaseNotPaidByRemaining];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

// 在确认环节通过余额支付
- (void)purchaseNotPaidByRemaining
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    [manager.requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/BuyDirectly/%@", USERID];
        NSMutableArray *paramArray = [[NSMutableArray alloc] init];
        if (self.listCart) {
            for (NSDictionary *rowDict in self.listCart) {
                NSDictionary *newDict = @{@"bookID": rowDict[@"bookID"], @"amount": rowDict[@"amount"]};
                [paramArray addObject:newDict];
            }
        }
        NSLog(@"path:%@",path);
        [manager POST:path parameters:paramArray success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                    [alert show];
                }
            }
            NSLog(@"purchaseToServerByRemaining Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"purchaseToServerByRemaining Error:%@", error);
        }];
    }
}

// User/Pay/ByRemaining/
- (void)purchaseToServerByRemaining
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/Pay/ByRemaining/%@", USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", @"查看电子小票",nil];
                    self.valueDict = @{@"status": [NSNumber numberWithInteger:fromPurchase], @"orderID": [NSString stringWithFormat:@"%@", retDict[@"orderID"]]};
                    alert.tag = 0;
                    [alert show];
                } else if ([retDict[@"message"] isEqualToString:@"remaining not enough"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付失败" message:@"你的账户余额不足，请充值后付款" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alert.tag = 1;
                    [alert show];
                }
            }
            NSLog(@"purchaseToServerByRemaining Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"purchaseToServerByRemaining Error:%@", error);
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
        if (buttonIndex == 1) {
            [self performSegueWithIdentifier:@"showInvoice" sender:nil];
        }
    }
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
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
