//
//  XYMakeCommentController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-30.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYMakeCommentController.h"
#import "XYStarRatedView.h"
#import "XYUtil.h"

@interface XYMakeCommentController ()
@property (weak, nonatomic) IBOutlet UILabel *bookName;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UITextView *content;
- (IBAction)pubComment:(id)sender;

@property int score;

@end

@implementation XYMakeCommentController

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
    
    [self prepareComment];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardByTouchDownBG)];
    [self.view addGestureRecognizer:tap];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)prepareComment
{
    self.bookName.text = [NSString stringWithFormat:@"\"%@\"", self.bname];
    
    CGRect rect = CGRectMake(0, 0, self.scoreView.frame.size.width, self.scoreView.frame.size.height);
    XYStarRatedView *starRateView = [[XYStarRatedView alloc] initWithFrame:rect numberOfStar:5 AtStatus:RATED];
    starRateView.delegate = self;
    [self.scoreView addSubview:starRateView];
    
    CGPoint p = CGPointMake(0, rect.size.height);
    [starRateView changeStarForegroundViewWithPoint:p];
    self.score = 0.0f;
}

-(void)starRatedView:(XYStarRatedView *)view score:(float)score
{
    self.score = score * 5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboardByTouchDownBG
{
    // NSLog(@"dismissKeyboardByTouchDownBG");
    [self.content resignFirstResponder];
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

- (IBAction)pubComment:(id)sender {
    if (self.content.text && ![self.content.text isEqualToString:@""]) {
        [self pubCommentToServer];
    }
}

- (void)pubCommentToServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    [manager.requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *path = @"AddBookComment";
    NSLog(@"path:%@",path);
    NSDictionary *params = @{@"userID": [NSNumber numberWithInt:[USERID intValue]], @"bookID": [NSNumber numberWithInt:[self.bookID intValue]], @"score":[NSNumber numberWithInt:self.score], @"content":self.content.text};
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"message"]) {
            NSLog(@"message: %@", retDict[@"message"]);
            if ([retDict[@"message"] isEqualToString:@"successful"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发布成功" message:@"评论发布成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                [alert show];
            }
        }
        NSLog(@"pubCommentToServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"pubCommentToServer Error:%@", error);
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
