//
//  XYUserInfoController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-5.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYUserInfoController.h"
#import "XYUtil.h"

@interface XYUserInfoController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *uname;
@property (weak, nonatomic) IBOutlet UILabel *credit;
@property (weak, nonatomic) IBOutlet UILabel *remaining;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *area;
@property (weak, nonatomic) IBOutlet UILabel *sign;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *phoneNum;

@end

@implementation XYUserInfoController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self loadUserInfoFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserInfoFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"User/UserInfo/" stringByAppendingString:USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *tmp = (NSDictionary *)responseObject;
            if (tmp && [tmp count] > 0) {
                self.uname.text = tmp[@"username"];
                self.nickname.text = (tmp[@"name"] == nil || [tmp[@"name"] isEqualToString:@""]) ? tmp[@"username"] : tmp[@"name"];
                int imageIdx = [tmp[@"headerimg"] intValue];
                self.headImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"headImg_%d.jpg", imageIdx]];
                self.credit.text = [NSString stringWithFormat:@"%@", tmp[@"score"]];
                self.remaining.text = [XYUtil printMoneyAtCent:[tmp[@"remaining"] intValue]];
                self.email.text = (tmp[@"email"] == nil || [tmp[@"email"] isEqualToString:@""]) ? @"无" : tmp[@"email"];
                self.gender.text = arc4random() % 2 == 0 ? @"男" : @"女";
                self.area.text = (tmp[@"address"] == nil || [tmp[@"address"] isEqualToString:@""]) ? @"无" : tmp[@"address"];
                self.phoneNum.text = (tmp[@"phonenumber"] == nil || [tmp[@"phonenumber"] isEqualToString:@""]) ? @"无" : tmp[@"phonenumber"];
                self.sign.text = (tmp[@"sign"] == nil || [tmp[@"sign"] isEqualToString:@""]) ? @"无" : tmp[@"sign"];
                [self.tableView reloadData];
            }
            NSLog(@"loadUserInfoFromServer Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadUserInfoFromServer Error:%@", error);
        }];
    }
}

//#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

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
