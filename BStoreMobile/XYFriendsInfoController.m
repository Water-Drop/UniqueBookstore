//
//  XYFriendsInfoController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-30.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYFriendsInfoController.h"
#import "XYUtil.h"
#import "XYRoundView.h"

@interface XYFriendsInfoController ()
@property (weak, nonatomic) IBOutlet XYRoundView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *sign;
@property (weak, nonatomic) IBOutlet UILabel *actionButton;

@end

@implementation XYFriendsInfoController

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
    
    if (self.status == ADD || self.status == INFO) {
        [self loadFriendInfo];
        if (self.status == INFO) {
            self.actionButton.text = @"已经是好友";
        }
    } else {
        self.actionButton.text = @"删除该好友";
        [self loadFriendFromServer];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadFriendInfo
{
    self.headImg.range = 4;
    int imgIndex = [self.head intValue];
    NSString *imagePath = [NSString stringWithFormat:@"headImg_%d.jpg", imgIndex];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.headImg.frame.size.width, self.headImg.frame.size.height)];
    imageView.image = [UIImage imageNamed:imagePath];
    [self.headImg addSubview:imageView];
    self.username.text = self.uname;
    self.gender.text = (self.gen == nil) ? @"" : self.gen;
    self.address.text = (self.addr == nil || [self.addr isEqualToString:@""]) ? @"无" : self.addr;
    self.sign.text = (self.sg == nil || [self.sg isEqualToString:@""]) ? @"无" : self.sg;
    self.name.text = (self.nickname == nil || [self.nickname isEqualToString:@""]) ? self.uname : self.nickname;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        NSLog(@"friendsInfo status %u", self.status);
        if (self.status == ADD) {
            [self addFriendFromServer];
        } else if (self.status == DELETE) {
            [self delFriendFromServer];
        }
    }
}

- (void) addFriendFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/AddFriend?userID1=%@&userID2=%@", USERID, self.userID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加成功" message:@"该用户已添加为你的好友" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
//                    alert.tag = ADD;
//                    [alert show];
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"添加成功" description:@"该用户已添加为你的好友" type:TWMessageBarMessageTypeSuccess];
                    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                }
            }
            NSLog(@"addFriendFromServer Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"addFriendFromServer Error:%@", error);
        }];
    }
}

- (void) delFriendFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/DeleteFriend?userID1=%@&userID2=%@", USERID, self.userID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除成功" message:@"该用户已从好友列表中删除" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
//                    alert.tag = DELETE;
//                    [alert show];
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"删除成功" description:@"该用户已从好友列表中删除" type:TWMessageBarMessageTypeSuccess];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            NSLog(@"delFriendFromServer Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"delFriendFromServer Error:%@", error);
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case ADD:
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        case DELETE:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

- (void) loadFriendFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"User/UserInfo/" stringByAppendingString:self.userID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *tmp = (NSDictionary *)responseObject;
        if (tmp && [tmp count] > 0) {
            self.sg = tmp[@"sign"];
            self.addr = tmp[@"address"];
            self.uname = tmp[@"username"];
            self.head = tmp[@"headerimg"];
            self.nickname = tmp[@"name"];
            NSString *genstr = nil;
            if (tmp[@"gender"]) {
                if ([tmp[@"gender"] intValue] == 0) {
                    genstr = @"男";
                } else if([tmp[@"gender"] intValue] == 1) {
                    genstr = @"女";
                } else {
                    genstr = @"";
                }
            } else {
                genstr = @"";
            }
            self.gen = genstr;
            [self loadFriendInfo];
            [self.tableView reloadData];
        }
        NSLog(@"loadFriendFromServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadFriendFromServer Error:%@", error);
    }];
}

//#pragma mark - Table view data source
//
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
