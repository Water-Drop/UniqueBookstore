//
//  XYConfirmController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-30.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYConfirmController.h"
#import "XYRecBookCell.h"
#import "XYCollectionCell.h"
#import "UIKit+AFNetworking.h"
#import "XYUtil.h"
#import "XYPurchaseController.h"

@interface XYConfirmController ()

@property (nonatomic, strong)NSArray *listOutput;
@property (nonatomic, strong)NSMutableArray *listPrint;
@property (nonatomic, strong)NSString *bsID;

@property (nonatomic, strong)NSMutableDictionary *sectionDict;

@property NSInteger notpaidPriceAtCent;

@end

@implementation XYConfirmController

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
    
    [self prepareToShow];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)prepareToShow
{
    self.notpaidPriceAtCent = 0;
    
    [self loadConfirmListFromServer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self prepareToShow];
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
    return self.listPrint == nil ? 0 : [self.listPrint count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.sectionDict) {
        if (self.sectionDict[@"correct"] && [self.sectionDict[@"correct"] intValue] == section) {
            return @"以下书籍验证通过";
        }
        if (self.sectionDict[@"notpaid"] && [self.sectionDict[@"notpaid"] intValue] == section) {
            return @"以下书籍尚未支付";
        }
        if (self.sectionDict[@"nottaken"] && [self.sectionDict[@"nottaken"] intValue] == section) {
            return @"以下书籍尚未带走";
        }
    }
    return nil;
}

// tell the delegate the table view is aobut to draw a cell for a pariticular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(XYRecBookCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:(indexPath.section)];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.listPrint[collectionView.tag] count];
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
    NSDictionary *rowDict = [self.listPrint[collectionView.tag] objectAtIndex:row];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"ConfirmListItemID";
    XYRecBookCell *cell = (XYRecBookCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[XYRecBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 152.0f;
}

- (void)loadConfirmListFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [NSString stringWithFormat:@"User/BooksInSAArea?userID=%@&bsID=%@", USERID, @"1"];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tmp = (NSArray *)responseObject;
        if (tmp) {
            self.listOutput = [[NSMutableArray alloc]initWithArray:tmp];
        }
        [self calculateListPrint];
        UIBarButtonItem *rightBtn = nil;
        UIBarButtonItem *leftBtn = nil;
        if (self.listOutput && [self.listOutput count] > 0) {
            rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
            leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
        }
        self.navigationItem.rightBarButtonItem = rightBtn;
        self.navigationItem.leftBarButtonItem = leftBtn;
        [self.tableView reloadData];
        NSLog(@"loadConfirmListFromServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadConfirmListFromServer Error:%@", error);
    }];
}

- (void)confirmAction
{
    if ([self.sectionDict objectForKey:@"notpaid"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"验证未通过" message:@"部分商品尚未支付" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续支付",nil];
        [alert show];
    } else {
        [self sendConfirmRequest];
    }
}

- (void)sendConfirmRequest
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [NSString stringWithFormat:@"User/SettleAccounts?userID=%@&bsID=%@", USERID, @"1"];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"message"]) {
            NSLog(@"%@", retDict[@"message"]);
            if ([retDict[@"message"] isEqualToString:@"successful"]) {
                [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
        NSLog(@"sendConfirmRequest Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sendConfirmRequest Error:%@", error);
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {// 继续支付
        [self performSegueWithIdentifier:@"purchase" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"purchase"]) {
        UIViewController *dest = ((UINavigationController *)segue.destinationViewController).viewControllers[0];
        // find notpaid book array
        int index = [self.sectionDict[@"notpaid"] intValue];
        NSArray *listCart = self.listPrint[index];
        [dest setValue:listCart forKey:@"listCart"];
        [dest setValue:[XYUtil printMoneyAtCent:self.notpaidPriceAtCent] forKeyPath:@"totalPriceStr"];
        [dest setValue:[NSNumber numberWithInteger:FROMNOTPAID] forKeyPath:@"statusNum"];
    }
}

- (void)cancelAction
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)calculateListPrint
{
    if (self.listOutput) {
        self.sectionDict = [[NSMutableDictionary alloc] init];
        self.listPrint = [[NSMutableArray alloc] init];
        NSMutableArray *listNotTaken = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *listCorrect = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *listNotPaid = [[NSMutableArray alloc] initWithCapacity:10];
        for (NSDictionary *rowDict in self.listOutput) {
            int curCnt = [rowDict[@"Aamount"] intValue];
            int buyCnt = [rowDict[@"Bamount"] intValue];
            int correct = (curCnt < buyCnt) ? curCnt : buyCnt;
            if (correct != 0) {
                NSMutableDictionary *subDict0 = [[NSMutableDictionary alloc] initWithDictionary:rowDict];
                [subDict0 removeObjectForKey:@"Aamount"];
                [subDict0 removeObjectForKey:@"Bamount"];
                subDict0[@"amount"] = [NSNumber numberWithInt:correct];
                [listCorrect addObject:subDict0];
            }
            NSMutableArray *tmp = nil;
            int remains = 0;
            if (curCnt < buyCnt) {
                remains = buyCnt - curCnt;
                tmp = listNotTaken;
            } else if (curCnt > buyCnt) {
                remains = curCnt - buyCnt;
                tmp = listNotPaid;
                int priceAtCent = [rowDict[@"price"] intValue];
                self.notpaidPriceAtCent += priceAtCent * remains;
            }
            if (curCnt != buyCnt) {
                NSMutableDictionary *subDict1 = [[NSMutableDictionary alloc] initWithDictionary:rowDict];
                [subDict1 removeObjectForKey:@"Aamount"];
                [subDict1 removeObjectForKey:@"Bamount"];
                subDict1[@"amount"] = [NSNumber numberWithInt:remains];
                [tmp addObject:subDict1];
            }
        }
        int begin = 0;
        if ([listCorrect count] > 0) {
            [self.sectionDict setValue:[NSNumber numberWithInt:begin] forKey:@"correct"];
            [self.listPrint addObject:listCorrect];
            begin ++;
        }
        if ([listNotPaid count] > 0) {
            [self.sectionDict setValue:[NSNumber numberWithInt:begin] forKey:@"notpaid"];
            [self.listPrint addObject:listNotPaid];
            begin ++;
        }
        
        if ([listNotTaken count] > 0) {
            [self.sectionDict setValue:[NSNumber numberWithInt:begin] forKey:@"nottaken"];
            [self.listPrint addObject:listNotTaken];
            begin ++;
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
