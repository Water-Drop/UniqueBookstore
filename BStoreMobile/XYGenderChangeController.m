//
//  XYGenderChangeController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-5.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYGenderChangeController.h"
#import "XYUtil.h"

@interface XYGenderChangeController ()
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

@implementation XYGenderChangeController

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
    
    switch (self.status) {
        case GENDER:
            self.navigationItem.title = @"修改性别";
            break;
        case LOCATION:
            self.navigationItem.title = @"修改公开地理位置信息";
            break;
        default:
            break;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status == GENDER) {
        NSString *cellIdentifier = @"GenderChangeCellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        // Configure the cell...
        
        NSString *lbl = @"男";
        if (indexPath.row == 1) {
            lbl = @"女";
        }
        
        UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:15];
        cell.textLabel.font = font;
        cell.textLabel.text = lbl;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BOOL pos = NO;
        if (self.gender) {
            if ([self.gender isEqualToString:@"男"] && indexPath.row == 0) {
                pos = YES;
            } else if ([self.gender isEqualToString:@"女"] && indexPath.row == 1) {
                pos = YES;
            }
        }
        if (pos) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    } else {
        NSString *cellIdentifier = @"GenderChangeCellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        // Configure the cell...
        
        NSString *lbl = @"公开";
        if (indexPath.row == 1) {
            lbl = @"不公开";
        }
        
        UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:15];
        cell.textLabel.font = font;
        cell.textLabel.text = lbl;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BOOL pos = NO;
        if (self.gender) {
            if ([self.gender isEqualToString:@"公开"] && indexPath.row == 0) {
                pos = YES;
            } else if ([self.gender isEqualToString:@"不公开"] && indexPath.row == 1) {
                pos = YES;
            }
        }
        if (pos) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status == GENDER) {
        if (indexPath.row == 0) {
            self.gender = @"男";
            [self.tableView reloadData];
        } else if (indexPath.row == 1) {
            self.gender = @"女";
            [self.tableView reloadData];
        }
    } else if (self.status == LOCATION) {
        if (indexPath.row == 0) {
            self.gender = @"公开";
            [self.tableView reloadData];
        } else if (indexPath.row == 1) {
            self.gender = @"不公开";
            [self.tableView reloadData];
        }
    }
}

- (void)modifyGenderInfo {
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    [manager.requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *path = @"User/UpdateUserInfo/gender";
    int gen = [self.gender isEqualToString:@"男"] ? 0 : 1;
    NSNumber *gender = [NSNumber numberWithInt:gen];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSDictionary *paramDict = @{@"userID": USERID, @"gender": gender};
        NSLog(@"path:%@\n paramDict:%@",path, paramDict);
        [manager POST:path parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
                    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                } else {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改失败" message:@"请重新尝试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                    [alert show];
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"修改失败"
                                                                   description:@"请重新尝试"
                                                                          type:TWMessageBarMessageTypeError
                                                                      callback:nil];
                }
            }
            NSLog(@"modifyGenderInfo Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"modifyGenderInfo Error:%@", error);
        }];
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

- (IBAction)cancelAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender {
    if (self.status == GENDER) {
        [self modifyGenderInfo];
    } else if (self.status == LOCATION) {
        [self modifyLocationInfo];
    }
}

- (void)modifyLocationInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:@"userInfo"];
    NSMutableDictionary *newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    [newUserInfo setObject:self.gender forKey:@"isToPublic"];
    [defaults setObject:newUserInfo forKey:@"userInfo"];
    [defaults synchronize];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
