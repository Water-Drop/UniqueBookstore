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
#import "XYPurchaseController.h"

@interface XYMyBookController ()

enum MyBookPageStatus {
    CART, TOBUY, PAID
};

@property (nonatomic, strong) NSMutableArray *listItem;
@property (nonatomic, strong) NSDictionary *valueDict;
@property enum MyBookPageStatus status;
@property (nonatomic,strong) NSMutableArray *listCart;
@property (nonatomic,strong) NSMutableArray *listToBuy;
@property (nonatomic,strong) NSMutableArray *listPaid;
@property (nonatomic, strong) UIButton *doneInKeyboardButton;
@property (nonatomic, strong) UIView *toolView;

@end

@implementation XYMyBookController

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
    [self prepareForToolView];
    [self changeStatus:CART];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardByTouchDownBG)];
//    [self.view addGestureRecognizer:tap];
}

// add ToolView with SegControl in section#1's header
- (void)prepareForToolView
{
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    NSArray *segItemsArray = [NSArray arrayWithObjects: @"购物车", @"心愿单", @"已购书籍", nil];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
//    [segControl setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [segControl setTintColor:[UIColor lightGrayColor]];
    segControl.frame = CGRectMake(16, 8, 287, 29);
    segControl.selectedSegmentIndex = 0;
    [segControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.toolView addSubview:segControl];
    self.toolView.backgroundColor = [UIColor whiteColor];
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
            return self.listPaid == nil ? 0 : [self.listPaid count];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 45.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        // 每次reload tableview时，均要调用，因此不能在此处alloc/init toolbar，应当将toolbar作为一个成员变量，只初始化一次
        return self.toolView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        self.valueDict = @{@"bookID": [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:cell.tag]]};
        [self performSegueWithIdentifier:@"BookDetail" sender:self];
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
        cell.buyButton.tag = indexPath.row;
        [cell.buyButton addTarget:self action:@selector(wishlistToCart:) forControlEvents:UIControlEventTouchUpInside];
        cell.navButton.tag = indexPath.row;
        [cell.navButton addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
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
        // add Done key in CntTextField
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"更新" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonDidPressed:)];
        doneItem.tag = row;
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonDidPressed:)];
        cancelItem.tag = row;
        UIBarButtonItem *flexableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[self class] toolbarHeight])];
        [toolbar setItems:[NSArray arrayWithObjects:cancelItem,flexableItem,doneItem, nil]];
        cell.cntText.inputAccessoryView = toolbar;
        
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
        
        cell.tobuyBtn.tag = indexPath.row;
        [cell.tobuyBtn addTarget:self action:@selector(cartToWishlist:) forControlEvents:UIControlEventTouchUpInside];
        
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
        NSDictionary *rowDict = [self.listPaid objectAtIndex:row];
        cell.title.text = rowDict[@"title"];
        
        NSString *detail = rowDict[@"author"];
        cell.detail.text = detail;
        
        NSNumber *num = rowDict[@"bookID"];
        cell.title.tag = [num integerValue];
        NSString *imagePath = rowDict[@"coverimg"];
        __weak XYPaidItemCell *weakCell = cell;
        [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakCell.coverImage.image = image;
            [weakCell setNeedsLayout];
            [weakCell setNeedsDisplay];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Get Image from Server Error.");
        }];
        
        cell.tag = [num integerValue];
        
        cell.comButton.tag = indexPath.row;
        [cell.comButton addTarget:self action:@selector(makeComment:) forControlEvents:UIControlEventTouchUpInside];
        
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
            [self loadPaidFromServer];
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
                self.navigationItem.leftBarButtonItem = nil;
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
    if ([segue.identifier isEqualToString:@"BookDetail"] || [segue.identifier isEqualToString:@"makeComment"] || [segue.identifier isEqualToString:@"purchase"]) {
        UIViewController *dest;
        if ([segue.identifier isEqualToString:@"BookDetail"]) {
            dest = segue.destinationViewController;
        } else {
            // modal(first is navigation controller)
            dest = ((UINavigationController *)segue.destinationViewController).viewControllers[0];
        }
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
            tmp = self.listPaid;
        }
        default:
            break;
    }
    if (tmp) {
        if (editingStyle == UITableViewCellEditingStyleDelete) // 等价于 self.status != PAID(defined in tableView:editingStyleForRowAtIndexPath:)
        {
            [tmp removeObjectAtIndex:indexPath.row];  //删除数组里的数据
            [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
            if (!tmp || [tmp count] == 0) {
                self.navigationItem.rightBarButtonItem = nil;
                self.navigationItem.leftBarButtonItem = nil;
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
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"User/MyCart/" stringByAppendingString:USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *tmp = (NSArray *)responseObject;
            if (tmp) {
                self.listCart = [[NSMutableArray alloc]initWithArray:tmp];
            }
            NSLog(@"loadCartFromServer Success");
            UIBarButtonItem *rightBtn = nil;
            UIBarButtonItem *leftBtn = nil;
            if (self.listCart && [self.listCart count] > 0) {
                rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItemsInCart)];
                leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"去付款" style:UIBarButtonItemStylePlain target:self action:@selector(goToPurchase)];
            }
            self.navigationItem.rightBarButtonItem = rightBtn;
            self.navigationItem.leftBarButtonItem = leftBtn;
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadCartFromServer Error:%@", error);
        }];
    }
}

-(void) goToPurchase {
    self.valueDict = @{@"statusNum": [NSNumber numberWithInteger:FROMCART]};
    [self performSegueWithIdentifier:@"purchase" sender:self];
}

-(void) loadToBuyFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"User/MyWishlist/" stringByAppendingString:USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *tmp = (NSArray *)responseObject;
            if (tmp) {
                self.listToBuy = [[NSMutableArray alloc]initWithArray:tmp];
            }
            NSLog(@"loadToBuyFromServer Success");
            UIBarButtonItem *rightBtn = nil;
            if (self.listToBuy && [self.listToBuy count] > 0) {
                rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItemsInTobuy)];
            }
            self.navigationItem.rightBarButtonItem = rightBtn;
            self.navigationItem.leftBarButtonItem = nil;
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadToBuyFromServer Error:%@", error);
        }];
    }
}

-(void) loadPaidFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"User/PurchasedBooks/" stringByAppendingString:USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *tmp = (NSArray *)responseObject;
            if (tmp) {
                self.listPaid = [[NSMutableArray alloc]initWithArray:tmp];
            }
            NSLog(@"loadPaidFromServer Success");
            self.navigationItem.rightBarButtonItem = nil;
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadPaidFromServer Error:%@", error);
        }];
    }
}

-(void) deleteItemsInCartFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
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
}

-(void) deleteItemsInWishlistFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
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
}

-(void) deleteOneItemInCartFromServer:(NSInteger) bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
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
}

-(void) deleteOneItemInWishlistFromServer:(NSInteger) bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
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
}

- (void)updateOneItemInCart:(NSInteger)bookID amount:(NSInteger)amount
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/UpdateCart?userID=%@&bookID=%@&amount=%@", USERID, [NSNumber numberWithInteger:bookID], [NSNumber numberWithInteger:amount]];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
            }
            [self.tableView reloadData];
            NSLog(@"updateOneItemInCart Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"updateOneItemInCart Error:%@", error);
        }];
    }
}

- (void)doneButtonDidPressed:(id)sender {
    NSInteger tag = ((UIBarButtonItem *)sender).tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    XYCartItemCell* cell = (XYCartItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.cntText resignFirstResponder];
    NSLog(@"doneButtonDidPressed Cell.cnText:%@", cell.cntText.text);
    if (cell.cntText.text && ![cell.cntText.text isEqualToString:@""]) {
        NSInteger amount = [cell.cntText.text intValue];
        if (amount == 0) {
            [self deleteOneItemInCartFromServer:cell.tag];
            [self.listCart removeObjectAtIndex:indexPath.row];  //删除数组里的数据
            [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
            if (!self.listCart || [self.listCart count] == 0) {
                self.navigationItem.rightBarButtonItem = nil;
                self.navigationItem.leftBarButtonItem = nil;
            }
        } else {
            [self updateOneItemInCart:cell.tag amount:amount];
            // 修改本地的listCart对应项的amount
            NSDictionary *rowDict = self.listCart[indexPath.row];
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:rowDict];
            [tmp setValue:[NSNumber numberWithInteger:amount] forKey:@"amount"];
            self.listCart[indexPath.row] = tmp;
        }
    }
    [self.tableView reloadData];
}

- (void)cancelButtonDidPressed:(id)sender {
    NSInteger tag = ((UIBarButtonItem *)sender).tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    XYCartItemCell* cell = (XYCartItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.cntText resignFirstResponder];
    NSLog(@"cancelButtonDidPressed Cell.cnText:%@", cell.cntText.text);
    [self.tableView reloadData];
}

+ (CGFloat)toolbarHeight {
    // This method will handle the case that the height of toolbar may change in future iOS.
    return 44.f;
}

-(IBAction)unwindToPaid:(UIStoryboardSegue *)segue
{
    
}

- (void)makeComment:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    if (self.listPaid) {
        NSDictionary *rowDict = self.listPaid[tag];
        NSNumber *bookID = rowDict[@"bookID"];
        NSString *title = rowDict[@"title"];
        self.valueDict = @{@"bookID": [NSString stringWithFormat:@"%@", bookID], @"bname": title};
        [self performSegueWithIdentifier:@"makeComment" sender:self];
    }
}

- (void)cartToWishlist:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self cartToWishlistInServer:cell.tag];
    if (self.listCart) {
        [self.listCart removeObjectAtIndex:indexPath.row];  //删除数组里的数据
        [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
        if (!self.listCart || [self.listCart count] == 0) {
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}

- (void)cartToWishlistInServer:(NSInteger)bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/Cart2Wishlist?userID=%@&bookID=%@&amount=1", USERID, [NSNumber numberWithInteger:bookID]];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"移入心愿单" message:@"该商品已成功移入心愿单" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                    [alert show];
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"移入心愿单"
                                                                   description:@"该商品已成功移入心愿单"
                                                                          type:TWMessageBarMessageTypeSuccess
                                                                      callback:nil];
                }
            }
            [self.tableView reloadData];
            NSLog(@"cartToWishlistInServer Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"cartToWishlistInServer Error:%@", error);
        }];
    }
}

- (void)wishlistToCart:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self wishlistToCartInServer:cell.tag];
    if (self.listToBuy) {
        [self.listToBuy removeObjectAtIndex:indexPath.row];  //删除数组里的数据
        [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
        if (!self.listToBuy || [self.listToBuy count] == 0) {
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}

- (void)wishlistToCartInServer:(NSInteger)bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/Wishlist2Cart?userID=%@&bookID=%@&amount=1", USERID, [NSNumber numberWithInteger:bookID]];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加到购物车" message:@"该商品已成功添加到购物车" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                    [alert show];
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"添加到购物车"
                                                                   description:@"该商品已成功添加到购物车"
                                                                          type:TWMessageBarMessageTypeSuccess
                                                                      callback:nil];
                }
            }
            [self.tableView reloadData];
            NSLog(@"wishlistToCartInServer Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"wishlistToCartInServer Error:%@", error);
        }];
    }
}

- (void)navButtonClicked:(id)sender
{
    [[XYLocationManager sharedManager] showNavigationModal];
}

//- (void)dismissKeyboardByTouchDownBG {
//    if (self.status == CART) {
//        NSArray *visibles = self.tableView.visibleCells;
//        for (XYCartItemCell *cell in visibles) {
//            if ([cell.cntText isFirstResponder]) {
//                [cell.cntText resignFirstResponder];
//                NSLog(@"dismissKeyboardByTouchDownBG Cell.cnText:%@", cell.cntText.text);
//                return;
//            }
//        }
//    }
//}

//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    // 输出点击的view的类名
//    NSLog(@"%@", NSStringFromClass([touch.view class]));
//    
//    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
//        return NO;
//    }
//    return  YES;
//}

@end
