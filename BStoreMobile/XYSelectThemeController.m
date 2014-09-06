//
//  XYSelectThemeController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-6.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYSelectThemeController.h"
#import "XYUtil.h"
#import "XYSaleItemCell.h"
#import "UIKit+AFNetworking.h"

@interface XYSelectThemeController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *listItem;

@property (nonatomic, strong) NSDictionary *valueDict;

@end

@implementation XYSelectThemeController

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
    
    if (self.tagName) {
        [self.navigationItem setTitle:self.tagName];
    }
    
    [XYUtil setExtraCellLineHidden:self.tableView];
    
    [self loadSelectThemeFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_listItem count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XYSaleItemCell *cell = (XYSaleItemCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        self.valueDict = @{@"bookID": [NSString stringWithFormat:@"%d", cell.tag]};
        [self performSegueWithIdentifier:@"BookDetail" sender:self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    NSDictionary *rowDict = [self.listItem objectAtIndex:row];
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
    
    [cell.buyButton addTarget:self action:@selector(buyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.buyButton.tag = [num intValue];
    
    [cell.navButton addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.navButton.tag = [num intValue];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103.0f;
}

#pragma control display content

- (void)loadSelectThemeFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"ClassContents/" stringByAppendingString:self.tagID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tmp = (NSArray *)responseObject;
        if (tmp) {
            self.listItem = [[NSMutableArray alloc]initWithArray:tmp];
        }
        NSLog(@"loadSelectThemeFromServer Success");
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadSelectThemeFromServer Error:%@", error);
    }];
}


#pragma button click action

- (IBAction)buyButtonClicked:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    if (tag > 0) {
        NSLog(@"Add bookID #%d To Cart", tag);
        [self addOneItemToCart:tag];
    }
}

- (IBAction)navButtonClicked:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    if (tag > 0) {
        NSLog(@"Nav bookID #%d ", tag);
    }
    [[XYLocationManager sharedManager] showNavigationModal];
}

- (void) addOneItemToCart:(NSInteger)bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/AddCart?userID=%@&bookID=%@&amount=1", USERID, [NSNumber numberWithInteger:bookID]];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加到购物车" message:@"该商品已成功添加到购物车" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
            }
            NSLog(@"addOneItemToCart Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"addOneItemToCart Error:%@", error);
        }];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
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
