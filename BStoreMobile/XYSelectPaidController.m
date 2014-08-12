//
//  TTSelectPaidController.m
//  TokenTextViewSample
//
//  Created by Julie on 14-8-11.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYSelectPaidController.h"
#import "XYPubMsgController.h"
#import "XYUtil.h"
#import "XYPaidItemCell.h"
#import "UIKit+AFNetworking.h"

@interface XYSelectPaidController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)cancelAction:(id)sender;
- (IBAction)updateAction:(id)sender;

@end

@implementation XYSelectPaidController

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
    if (!self.listPaid || !self.listPaidName) {
        NSLog(@"loadPaidFromServer in SelectPaid");
        [self loadPaidFromServer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listPaid count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SelectedPaidCellID";
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
    
    [cell.comButton setHidden:YES];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XYPaidItemCell *cell = (XYPaidItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSNumber *selectID = [NSNumber numberWithInteger:cell.tag];
    NSString *selectItem = cell.title.text;
    UINavigationController *nav = (UINavigationController *)self.presentingViewController;
    NSInteger idx = [nav.viewControllers count] - 1;
    XYPubMsgController *pm = nav.viewControllers[idx];
    NSLog(@"parentViewController class:%@", NSStringFromClass([pm class]));
    pm.selectItem = selectItem;
    pm.selectID = selectID;
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) loadPaidFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"User/PurchasedBooks/" stringByAppendingString:USERID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tmp = (NSArray *)responseObject;
        if (tmp) {
            self.listPaid = [[NSMutableArray alloc]initWithArray:tmp];
            self.listPaidName = [[NSMutableArray alloc] init];
            for (NSDictionary *rowDict in self.listPaid) {
                if ([rowDict objectForKey:@"title"]) {
                    [self.listPaidName addObject:[rowDict objectForKey:@"title"]];
                }
            }
        }
        [self.tableView reloadData];
        NSLog(@"loadPaidFromServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadPaidFromServer Error:%@", error);
    }];
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

- (IBAction)cancelAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateAction:(id)sender {
    [self loadPaidFromServer];
}
@end
