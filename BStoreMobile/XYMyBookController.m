//
//  MyBookController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-14.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYMyBookController.h"
#import "XYSaleItemCell.h"
#import "XYCartItemCell.h"
#import "XYPaidItemCell.h"
#import "XYUtil.h"
#import "UIKit+AFNetworking.h"

@interface XYMyBookController ()

enum MyBookPageStatus {
    CART, TOBUY, PAID
};

@property (nonatomic, strong) NSMutableArray *listItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *valueDict;
@property enum MyBookPageStatus status;
@property (nonatomic,strong) NSMutableArray *listCart;
@property (nonatomic,strong) NSMutableArray *listToBuy;
@property (nonatomic,strong) NSMutableArray *listPaid;
@property UIButton *doneInKeyboardButton;

- (IBAction)valueChanged:(id)sender;

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
    [self changeStatus:CART];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self changeStatus:self.status];
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
    switch (self.status) {
        case PAID: {
            return self.listItem == nil ? 0 : [self.listItem count];
        }
        case TOBUY: {
            return self.listToBuy == nil ? 0 : [self.listToBuy count];
        }
        case CART: {
            return self.listCart == nil ? 0 : [self.listCart count];
        }
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status == PAID) {
        XYPaidItemCell *cell = (XYPaidItemCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            self.valueDict = @{@"titleStr": cell.title.text, @"detailStr": cell.detail.text};
            [self performSegueWithIdentifier:@"BookDetail" sender:self];
        }
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            self.valueDict = @{@"bookID": [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:cell.tag]]};
            [self performSegueWithIdentifier:@"BookDetail" sender:self];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"XYMyBookController cellForRowAtIndexPath");
    
    /* // 不在/在sb中的tableview里添加prototype，从storyboard创建
    static NSString *CellIdentifier = @"CellIdentifier";
    XYSaleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[XYSaleItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    */
    
    if (self.status == TOBUY) {
        // 从xib中创建，不在sb中的tableview里添加prototype(否则关联的outlet是nil，没有初始化，main interface是sb)
        static NSString *cellIdentifier = @"SaleItemCellIdentifier";
        XYSaleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYSaleItemCell" owner:nil options:nil];
            //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        
        // Configure the cell...
        NSUInteger row = [indexPath row];
        NSDictionary *rowDict = [self.listToBuy objectAtIndex:row];
        cell.title.text = rowDict[@"title"];
        
        NSString *detail = rowDict[@"author"];
        cell.detail.text = detail;
        
        int priceAtCent = [rowDict[@"price"] intValue];
        NSString *priceStr = [XYUtil printMoneyAtCent:priceAtCent];
        [cell.buyButton setTitle:priceStr forState:UIControlStateNormal];
        
        NSNumber *num = rowDict[@"bookID"];
        cell.title.tag = [num integerValue];
        NSString *imagePath = rowDict[@"coverimg"];
        __weak XYSaleItemCell *weakCell = cell;
        [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakCell.coverImage.image = image;
            [weakCell setNeedsLayout];
            [weakCell setNeedsDisplay];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Get Image from Server Error.");
        }];
        
        cell.tag = [num integerValue];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else if(self.status == CART) {
        // 从xib中创建，不在sb中的tableview里添加prototype(否则关联的outlet是nil，没有初始化，main interface是sb)
        static NSString *cellIdentifier = @"CartItemCellIdentifier";
        XYCartItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYCartItemCell" owner:nil options:nil];
            //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        
        // Configure the cell...
        NSUInteger row = [indexPath row];
        NSDictionary *rowDict = [self.listCart objectAtIndex:row];
        cell.title.text = rowDict[@"title"];
        
        NSString *detail = rowDict[@"author"];
        cell.detail.text = detail;
        
        int amount = [rowDict[@"amount"] intValue];
        cell.cntText.text = [NSString stringWithFormat:@"%d", amount];
        
        int eachPriceAtCent = [rowDict[@"price"] intValue];
        int totPriceAtCent = eachPriceAtCent * amount;
        
        cell.eachPrice.text = [XYUtil printMoneyAtCent:eachPriceAtCent];
        cell.totalPrice.text = [XYUtil printMoneyAtCent:totPriceAtCent];
        
        NSNumber *num = rowDict[@"bookID"];
        cell.title.tag = [num integerValue];
        NSString *imagePath = rowDict[@"coverimg"];
        __weak XYCartItemCell *weakCell = cell;
        [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakCell.coverImage.image = image;
            [weakCell setNeedsLayout];
            [weakCell setNeedsDisplay];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Get Image from Server Error.");
        }];
        
        cell.tag = [num integerValue];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        // 从xib中创建，不在sb中的tableview里添加prototype(否则关联的outlet是nil，没有初始化，main interface是sb)
        static NSString *cellIdentifier = @"PaidItemCellIdentifier";
        XYPaidItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYPaidItemCell" owner:nil options:nil];
            //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        
        // Configure the cell...
        NSUInteger row = [indexPath row];
        NSDictionary *rowDict = [self.listItem objectAtIndex:row];
        cell.title.text = [rowDict objectForKey:@"name"];
        
        NSString *imagePath = [rowDict objectForKey:@"image"];
        imagePath = [imagePath stringByAppendingString:@".png"];
        cell.coverImage.image = [UIImage imageNamed:imagePath];
        
        NSString *detail = [rowDict objectForKey:@"detail"];
        cell.detail.text = detail;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;

    }
}

// 系统是先调用 heightForRowAtIndexPath 方法的，再调用cellForRowAtIndexPath。
// 动态分配cell大小，可以通过dictionary或者array

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103.0f;
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
            // NSLog(@"Seg Control valued changed to 0");
            [self changeStatus:CART];
            break;
        case 1:
            // NSLog(@"Seg Control valued changed to 1");
            [self changeStatus:TOBUY];
            break;
        case 2:
            // NSLog(@"Seg Control valued changed to 2");
            [self changeStatus:PAID];
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
    self.listItem = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    NSLog(@"XYMyBookController loadPlistFile from %@.%@ %lu",path, type,(unsigned long)[self.listItem count]);
}

- (void) changeStatus:(enum MyBookPageStatus)status
{
    self.status = status;
    UIBarButtonItem *rightBtn = nil;
    switch (status) {
        case CART:
            [self loadCartFromServer];
            break;
        case TOBUY:
            [self loadToBuyFromServer];
            break;
        case PAID:
            [self loadPaid];
            self.navigationItem.rightBarButtonItem = rightBtn;
            break;
        default:
            break;
    }
    
}

- (void) deleteItemsInCart
{
    NSLog(@"deleteItemsInCart");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清空购物车" message:@"确定删除购物车中所有商品？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    // optional - add more buttons
    // [alert addButtonWithTitle:@"确定"];
    alert.tag = 0;
    [alert show];
}

- (void) deleteItemsInTobuy
{
    NSLog(@"deleteItemsInTobuy");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清空心愿单" message:@"确定删除心愿单中所有商品？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    // optional - add more buttons
    // [alert addButtonWithTitle:@"确定"];
    alert.tag = 1;
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView tag in mybook:%ld", (long)alertView.tag);
    // Yes == 1
    switch (alertView.tag) {
        case 0:
            NSLog(@"CartAlertView: %ld", (long)buttonIndex);
            if (buttonIndex == 1) {
                [self.listCart removeAllObjects];
                [self deleteItemsInCartFromServer];
                self.navigationItem.rightBarButtonItem = nil;
                [self.tableView reloadData];
            }
            break;
        case 1:
            NSLog(@"TobuyAlertView: %ld", (long)buttonIndex);
            if (buttonIndex == 1) {
                [self.listToBuy removeAllObjects];
                [self deleteItemsInWishlistFromServer];
                self.navigationItem.rightBarButtonItem = nil;
                [self.tableView reloadData];
            }
            break;
        default:
            break;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BookDetail"]) {
        UIViewController *dest = segue.destinationViewController;
        if (self.valueDict) {
            for (NSString *key in self.valueDict) {
                NSLog(@"%@, %@", key, self.valueDict[key]);
                [dest setValue:self.valueDict[key] forKey:key];
            }
        }
    }
}

// delete from table view in Cart and tobuy
/*设置状态 only in cart and tobuy list*/
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status != PAID) {
        return  UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *tmp = nil;
    switch (self.status) {
        case CART: {
            tmp = self.listCart;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSInteger tag = cell.tag;
            [self deleteOneItemInCartFromServer:tag];
            break;
        }
        case TOBUY: {
            tmp = self.listToBuy;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSInteger tag = cell.tag;
            [self deleteOneItemInWishlistFromServer:tag];
            break;
        }
        case PAID: {
            tmp = self.listItem;
        }
        default:
            break;
    }
    if (tmp) {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            [tmp removeObjectAtIndex:indexPath.row];  //删除数组里的数据
            [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
            if (!tmp || [tmp count] == 0) {
                self.navigationItem.rightBarButtonItem = nil;
            }
        }
    }
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
    NSString *path = [@"User/MyCart/" stringByAppendingString:USERID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tmp = (NSArray *)responseObject;
        if (tmp) {
            self.listCart = [[NSMutableArray alloc]initWithArray:tmp];
        }
        NSLog(@"loadCartFromServer Success");
        [self.tableView reloadData];
        UIBarButtonItem *rightBtn = nil;
        if (self.listCart && [self.listCart count] > 0) {
            rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItemsInCart)];
        }
        self.navigationItem.rightBarButtonItem = rightBtn;
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadCartFromServer Error:%@", error);
    }];
}

-(void) loadToBuyFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"User/MyWishlist/" stringByAppendingString:USERID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tmp = (NSArray *)responseObject;
        if (tmp) {
            self.listToBuy = [[NSMutableArray alloc]initWithArray:tmp];
        }
        NSLog(@"loadToBuyFromServer Success");
        [self.tableView reloadData];
        UIBarButtonItem *rightBtn = nil;
        if (self.listToBuy && [self.listToBuy count] > 0) {
            rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItemsInTobuy)];
        }
        self.navigationItem.rightBarButtonItem = rightBtn;
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadToBuyFromServer Error:%@", error);
    }];
}

-(void) loadPaidFromServer
{
    
}

-(void) deleteItemsInCartFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [NSString stringWithFormat:@"User/DeleteCart/All?userID=%@", USERID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"message"]) {
            NSLog(@"message: %@", retDict[@"message"]);
        }
        NSLog(@"deleteItemsInCartFromServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"deleteItemsInCartFromServer Error:%@", error);
    }];
}

-(void) deleteItemsInWishlistFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [NSString stringWithFormat:@"User/DeleteWishlist/All?userID=%@", USERID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"message"]) {
            NSLog(@"message: %@", retDict[@"message"]);
        }
        NSLog(@"deleteItemsInWishlistFromServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"deleteItemsInWishlistFromServer Error:%@", error);
    }];
}

-(void) deleteOneItemInCartFromServer:(NSInteger) bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [NSString stringWithFormat:@"User/DeleteCart/Part?userID=%@&bookID=%@", USERID, [NSNumber numberWithInteger:bookID]];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"message"]) {
            NSLog(@"message: %@", retDict[@"message"]);
        }
        NSLog(@"deleteOneItemInCartFromServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"deleteOneItemInCartFromServer Error:%@", error);
    }];
}

-(void) deleteOneItemInWishlistFromServer:(NSInteger) bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [NSString stringWithFormat:@"User/DeleteWishlist/Part?userID=%@&bookID=%@", USERID, [NSNumber numberWithInteger:bookID]];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"message"]) {
            NSLog(@"message: %@", retDict[@"message"]);
        }
        NSLog(@"deleteOneItemInWishlistFromServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"deleteOneItemInWishlistFromServer Error:%@", error);
    }];
}

@end
