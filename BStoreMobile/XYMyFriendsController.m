//
//  XYMyFriendsController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-29.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYMyFriendsController.h"
#import "XYUtil.h"
#import "UIKit+AFNetworking.h"

@interface XYMyFriendsController ()

@property (nonatomic,strong) NSMutableArray *listFriends;
@property (nonatomic,strong) NSDictionary *valueDict;

@end

@implementation XYMyFriendsController

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
    
    [self loadFriendsFromServer];
    [XYUtil setExtraCellLineHidden:self.tableView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self loadFriendsFromServer];
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
    return self.listFriends == nil ? 0 : [self.listFriends count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MyFriendsCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    NSDictionary *rowDict = self.listFriends[indexPath.row];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 8, 52, 57)];
    imageView.image = [UIImage imageNamed:@"5.JPG"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(89, 26, 211, 21)];
    label.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    label.text = rowDict[@"username"];
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:label];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSNumber *num = rowDict[@"userID"];
    cell.tag = [num integerValue];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
     NSString *userID = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:cell.tag]];
    self.valueDict = @{@"userID": userID};
    [self performSegueWithIdentifier:@"friendsInfo" sender:self];
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

- (void) loadFriendsFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"User/Friendslist/" stringByAppendingString:USERID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tmp = (NSArray *)responseObject;
        if (tmp) {
            self.listFriends = [[NSMutableArray alloc]initWithArray:tmp];
        }
        NSLog(@"loadFriendsFromServer Success");
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadFriendsFromServer Error:%@", error);
    }];
}

@end
