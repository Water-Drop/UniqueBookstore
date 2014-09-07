//
//  XYFriendsMsgController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-29.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYFriendsMsgController.h"
#import "XYUtil.h"
#import "XYFriendsMsgCell.h"
#import "XYAutoLayoutLabel.h"

@interface XYFriendsMsgController ()

@property (nonatomic, strong) NSMutableArray *listMsg;
@property NSInteger delSayingCellRow;
@property NSInteger delSayingID;

@end

@implementation XYFriendsMsgController

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
    
    [self loadFriendsMsgFromServer];
    
    [XYUtil setExtraCellLineHidden:self.tableView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self loadFriendsMsgFromServer];
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
    return self.listMsg == nil ? 0 : [self.listMsg count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FriendsMsgCellIdentifier";
    XYFriendsMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // XYFriendsMsgCell.xib as NibName
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYFriendsMsgCell" owner:nil options:nil];
        //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    NSDictionary *rowDict = self.listMsg[indexPath.row];
    cell.headImg.range = 4;
    int imgIndex = [rowDict[@"headerimg"] intValue];
    NSString *imagePath = [NSString stringWithFormat:@"headImg_%d.jpg", imgIndex];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.headImg.frame.size.width, cell.headImg.frame.size.height)];
    imageView.image = [UIImage imageNamed:imagePath];
    [cell.headImg addSubview:imageView];
    NSString *displayName = (rowDict[@"name"] == nil || [rowDict[@"name"] isEqualToString:@""]) ? rowDict[@"username"] : rowDict[@"name"];
    cell.username.text = [NSString stringWithFormat:@"\"%@\"", displayName];
    cell.content.font = [UIFont fontWithName:@"Helvetica" size:12];
    cell.content.text = rowDict[@"content"];
    cell.pubDate.text = rowDict[@"date"];
    
    NSString *USERID = [XYUtil getUserID];
    if (USERID && rowDict[@"userID"]) {
        if ([USERID intValue] == [rowDict[@"userID"] intValue]) {
            [cell.delButton setHidden:NO];
            [cell.delButton addTarget:self action:@selector(delSaying:) forControlEvents:UIControlEventTouchUpInside];
            cell.delButton.tag = [rowDict[@"sayingID"] intValue];
            self.delSayingID = cell.delButton.tag;
        } else {
            [cell.delButton setHidden:YES];
        }
    } else {
        [cell.delButton setHidden:YES];
    }
    self.delSayingCellRow = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void) loadFriendsMsgFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"User/Sayinglist/" stringByAppendingString:USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *tmp = (NSArray *)responseObject;
            if (tmp) {
                self.listMsg = [[NSMutableArray alloc]initWithArray:tmp];
            }
            NSLog(@"loadFriendsMsgFromServer Success");
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadFriendsMsgFromServer Error:%@", error);
        }];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XYAutoLayoutLabel *lbl = [[XYAutoLayoutLabel alloc] initWithFrame:CGRectMake(68, 56, 232, 21)];
    NSDictionary *rowDict = self.listMsg[indexPath.row];
    lbl.font = [UIFont fontWithName:@"Helvetica" size:12];
    lbl.text = rowDict[@"content"];
    return lbl.frame.origin.y + lbl.frame.size.height + 10.0f;
}

-(IBAction)unwindToFriendsMsg:(UIStoryboardSegue *)segue
{
    
}

- (void)delSaying:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    if (tag > 0) {
        NSLog(@"Del sayingID #%d ", tag);
        NSLog(@"delSaying");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定删除" message:@"确定要删除所选消息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.tag = 0;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 1 && self.delSayingID > 0) {
            NSLog(@"delSaying button clicked.");
            [self.listMsg removeObjectAtIndex:self.delSayingCellRow];  //删除数组里的数据
            [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:self.delSayingCellRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
            [self delSayingFromServer:self.delSayingID];
        }
    }
}

- (void)delSayingFromServer:(NSInteger)sayingID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/DeleteSaying?userID=%@&sayingID=%@", USERID, [NSNumber numberWithInteger:sayingID]];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
            }
            NSLog(@"delSayingFromServer Success");
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"delSayingFromServer Error:%@", error);
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

@end
