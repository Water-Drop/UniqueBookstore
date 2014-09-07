//
//  XYChangeSignController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-8.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYSignChangeController.h"
#import "XYUtil.h"

#define MAXSIGN 30

@interface XYSignChangeController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *remains;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

@implementation XYSignChangeController

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
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *txt = [self calculateSign:textView.text];
    NSInteger txtlen = (txt == nil) ? 0 : [txt length];
    self.remains.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:(MAXSIGN - txtlen)]];
    textView.text = txt;
}

- (NSString *)calculateSign:(NSString *)txt
{
    NSInteger txtlen = (txt == nil) ? 0 : [txt length];
    int min = (txtlen < MAXSIGN) ? txtlen : MAXSIGN;
    NSLog(@"%d %d %d", txtlen, MAXSIGN, min);
    NSInteger end = min;
    if (end == 0) {
        return @"";
    } else {
        return [txt substringToIndex:end];
    }
}

- (IBAction)saveAction:(id)sender {
    [self modifySignInfo];
}

- (IBAction)cancelAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)modifySignInfo {
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    [manager.requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *path = @"User/UpdateUserInfo/sign";
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSDictionary *paramDict = @{@"userID": USERID, @"sign": [self calculateSign:self.textView.text]};
        NSLog(@"path:%@\n paramDict:%@",path, paramDict);
        [manager POST:path parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
                    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改失败" message:@"请重新尝试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
            }
            NSLog(@"modifySignInfo Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"modifySignInfo Error:%@", error);
        }];
    }
}
@end
