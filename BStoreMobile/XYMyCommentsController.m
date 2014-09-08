//
//  XYMyCommentsController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-8.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYMyCommentsController.h"
#import "XYUtil.h"
#import "XYMyCommentViewCell.h"
#import "UIKit+AFNetworking.h"

@interface XYMyCommentsController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listComments;

@end

@implementation XYMyCommentsController

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
    [XYUtil setExtraCellLineHidden:self.tableView];
    [self loadMyCommentsFromServer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self loadMyCommentsFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *commentsCellID = @"MyCommentsCellIdentifier";
    XYMyCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentsCellID];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYMyCommentViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *rowDict = [self.listComments objectAtIndex:indexPath.row];
    cell.uname.text = [NSString stringWithFormat:@"\"%@\"", rowDict[@"title"]];
    cell.pubDate.text = rowDict[@"date"];
    cell.upCnt.text = [NSString stringWithFormat:@"%d", [rowDict[@"favorCount"] intValue]];
    cell.downCnt.text = [NSString stringWithFormat:@"%d", [rowDict[@"againstCount"] intValue]];
    cell.content.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    cell.content.text = rowDict[@"content"];
    cell.tag = [rowDict[@"commentID"] intValue];
    NSString *imagePath = rowDict[@"coverimg"];
    __weak XYMyCommentViewCell *weakCell = cell;
    [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakCell.coverImage.image = image;
        [weakCell setNeedsLayout];
        [weakCell setNeedsDisplay];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Get Image from Server Error.");
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XYAutoLayoutLabel *lbl = [[XYAutoLayoutLabel alloc] initWithFrame:CGRectMake(63, 44, 237, 20)];
    lbl.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    NSDictionary *rowDict = self.listComments[indexPath.row];
    lbl.text = rowDict[@"content"];
    return lbl.frame.origin.y + lbl.frame.size.height + 10.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listComments == nil ? 0 : [self.listComments count];
}

// delete from table view in Cart and tobuy
/*设置状态 only in cart and tobuy list*/
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleDelete;
}

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *tmp = self.listComments;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger tag = cell.tag;
    [self deleteOneCommentFromServer:tag];
    if (tmp) {
        if (editingStyle == UITableViewCellEditingStyleDelete) // 等价于 self.status != PAID(defined in tableView:editingStyleForRowAtIndexPath:)
        {
            [tmp removeObjectAtIndex:indexPath.row];  //删除数组里的数据
            [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
        }
    }
}

- (void)deleteOneCommentFromServer:(NSInteger)commentID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/DeleteBookComment?userID=%@&commentID=%@", USERID, [NSNumber numberWithInteger:commentID]];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
            }
            NSLog(@"deleteOneCommentFromServer Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"deleteOneCommentFromServer Error:%@", error);
        }];
    }
}

- (void)loadMyCommentsFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [@"User/BookCommentByUser/" stringByAppendingString:USERID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *tmp = (NSArray *)responseObject;
            if (tmp) {
                self.listComments = [[NSMutableArray alloc]initWithArray:tmp];
            }
            NSLog(@"loadMyCommentsFromServer Success");
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadMyCommentsFromServer Error:%@", error);
        }];
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
