//
//  XYAddFriendsController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-24.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYAddFriendsController.h"
#import "XYUtil.h"
#import "XYFriendsInfoController.h"

@interface XYAddFriendsController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)dismissKeyboardByReturn:(id)sender;
- (IBAction)searchUserByName:(id)sender;
- (IBAction)cancelAction:(id)sender;
@property (nonatomic,strong) NSDictionary *valueDict;

@end

@implementation XYAddFriendsController

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardByTouchDownBG)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    self.textField.enablesReturnKeyAutomatically = YES;
    
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

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/

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

- (IBAction)dismissKeyboardByReturn:(id)sender
{
    [sender resignFirstResponder];
    [self searchUserByNameFromServer];
}

- (IBAction)searchUserByName:(id)sender {
    if (self.textField.text && ![self.textField.text isEqual:@""]) {
        [self.textField resignFirstResponder];
        [self searchUserByNameFromServer];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchUserByNameFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
//    NSString *path = [@"User/UserInfoUsername/" stringByAppendingString:[self.textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/UserInfoUsernameV2?userID=%@&username=%@", USERID, [self.textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *tmp = (NSDictionary *)responseObject;
            if (tmp && [tmp count] > 0) {
                NSString *USERID = [XYUtil getUserID];
                if (USERID && [tmp[@"userID"] intValue] != [USERID intValue]) {
                    NSString *userID = [NSString stringWithFormat:@"%@",tmp[@"userID"]];
                    NSString *sign = tmp[@"sign"];
                    NSString *address = tmp[@"address"];
                    NSString *username = tmp[@"username"];
                    NSNumber *head = tmp[@"headerimg"];
                    NSString *nickname = tmp[@"name"];
                    NSNumber *isFriends = tmp[@"isFriends"];
                    enum friendsInfoStatus status = ADD;
                    if ([isFriends intValue] == 1) {
                        status = DELETE;
                    }
                    self.valueDict = @{@"userID":userID, @"uname":username, @"gen":@"男", @"addr":address, @"sg": sign, @"status": [NSNumber numberWithInteger:status], @"head":head, @"nickname": nickname};
                    [self performSegueWithIdentifier:@"friendsInfo" sender:self];
                } else {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"你不能添加自己为好友" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                    [alert show];
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"你不能添加自己为好友"
                                                                   description:nil
                                                                          type:TWMessageBarMessageTypeError
                                                                      callback:nil];
                }
            } else {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该用户不存在" message:@"无法找到该用户，请检查你填写的账号是否正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                [alert show];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"该用户不存在"
                                                               description:nil
                                                                      type:TWMessageBarMessageTypeError
                                                                  callback:nil];
            }
            NSLog(@"searchUserNameFromServer Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"searchUserNameFromServer Error:%@", error);
        }];
    }
}

- (void)dismissKeyboardByTouchDownBG
{
    // NSLog(@"dismissKeyboardByTouchDownBG");
    [self.textField resignFirstResponder];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"friendsInfo"]) {
        UIViewController *dest = segue.destinationViewController;
        if (self.valueDict) {
            for (NSString *key in self.valueDict) {
                NSLog(@"%@, %@", key, self.valueDict[key]);
                [dest setValue:self.valueDict[key] forKey:key];
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    NSLog(@"Click View Name:%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}


@end
