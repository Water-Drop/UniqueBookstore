//
//  XYLabelChangeController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-5.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYLabelChangeController.h"
#import "XYUtil.h"

@interface XYLabelChangeController ()

- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation XYLabelChangeController

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
    
    switch (self.status) {
        case NICKNAME:
            [self.navigationItem setTitle:@"修改昵称"];
            self.textField.keyboardType = UIKeyboardTypeDefault;
            break;
        case REMAINING:
            [self.navigationItem setTitle:@"增加余额"];
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case PHONE:
            [self.navigationItem setTitle:@"修改联系电话"];
            self.textField.keyboardType = UIKeyboardTypePhonePad;
            break;
        case AREA:
            [self.navigationItem setTitle:@"修改地区"];
            self.textField.keyboardType = UIKeyboardTypeDefault;
            break;
        case EMAIL:
            [self.navigationItem setTitle:@"修改邮箱地址"];
            self.textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        default:
            break;
    }
    
    self.textField.text = self.oldLbl;
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)cancelAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender {
    [self modifyUserInfo];
}

- (void)modifyUserInfo {
    NSString *field = nil;
    NSString *key = nil;
    switch (self.status) {
        case NICKNAME:
            field = @"name";
            key = @"name";
            break;
        case REMAINING:
            field = @"AddRemaining";
            key = @"value";
            break;
        case PHONE:
            field = @"phonenumber";
            key = @"phonenumber";
            break;
        case AREA:
            field = @"address";
            key = @"address";
            break;
        case EMAIL:
            field = @"email";
            key = @"email";
            break;
        default:
            break;
    }
    
    if (field && key) {
        NSURL *url = [NSURL URLWithString:BASEURLSTRING];
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
        [manager.requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSString *path = [@"User/UpdateUserInfo/" stringByAppendingString:field];
        NSString *content = self.textField.text;
        NSString *USERID = [XYUtil getUserID];
        if (USERID) {
            NSDictionary *paramDict = nil;
            if (self.status != REMAINING) {
                paramDict = @{@"userID": USERID, key: content};
            } else {
                NSNumber *value = (content == nil || ![XYUtil isPureInt:content]) ? [NSNumber numberWithInt:0*100] : [NSNumber numberWithInt:([content intValue]*100)];
                paramDict = @{@"userID": USERID, key: value};
            }
            NSLog(@"path:%@\n paramDict:%@",path, paramDict);
            [manager POST:path parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *retDict = (NSDictionary *)responseObject;
                if (retDict && retDict[@"message"]) {
                    NSLog(@"message: %@", retDict[@"message"]);
                    if ([retDict[@"message"] isEqualToString:@"successful"]) {
                        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改失败" message:@"请重新尝试一次" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                    }
                }
                NSLog(@"modifyUserInfo Success");
            }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"modifyUserInfo Error:%@", error);
            }];
        }
    }
}

@end
