//
//  XYPubMsgController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-21.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYPubMsgController.h"

enum pubStatus {
    PUBLIC, PRIVATE
};

@interface XYPubMsgController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property enum pubStatus status;
- (IBAction)pubMsg:(id)sender;
@property NSInteger bookID;
@property BOOL pubToPublic;


@end

@implementation XYPubMsgController

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
    
    self.status = PRIVATE;
    self.pubToPublic = NO;
    
    self.textView.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardByTouchDownBG)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"PubMsgCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    UIColor *color = [UIColor lightGrayColor];
    if (self.pubToPublic == YES) {
        color = [UIColor blackColor];
    } else {
        self.status = PRIVATE;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"仅好友圈可见";
        if (self.status == PUBLIC) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (self.status == PRIVATE) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } if (indexPath.row == 1) {
        cell.textLabel.text = @"公共可见（同步到书籍评论）";
        if (self.status == PUBLIC) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else if (self.status == PRIVATE) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    cell.textLabel.textColor = color;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pubToPublic) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        int others = (indexPath.row == 0 ? 1 : 0);
        self.status = (indexPath.row == 0 ? PRIVATE : PUBLIC);
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:others inSection:0];
        UITableViewCell *otherCell = [self.tableView cellForRowAtIndexPath:otherIndexPath];
        otherCell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSLog(@"pub status:%u", self.status);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"选择消息的发布方式";
    } else {
        return nil;
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

#pragma mark - unused

- (void)dismissKeyboardByTouchDownBG
{
    // NSLog(@"dismissKeyboardByTouchDownBG");
    [self.textView resignFirstResponder];
}

- (IBAction)pubMsg:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发布成功" message:@"你已成功发送消息" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSRange foundObj=[textView.text rangeOfString:@"#" options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        self.pubToPublic = YES;
    } else {
        self.pubToPublic = NO;
    }
    if ([textView.text hasSuffix:@"#"]) {
        NSLog(@"Ended with #");
    }
    [self.tableView reloadData];
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
