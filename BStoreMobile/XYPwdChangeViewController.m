//
//  XYPwdChangeViewController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-10.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYPwdChangeViewController.h"
#import "XYUtil.h"

@interface XYPwdChangeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPwd;
@property (weak, nonatomic) IBOutlet UITextField *pwd0;
@property (weak, nonatomic) IBOutlet UITextField *pwd1;
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

@implementation XYPwdChangeViewController

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardByTouchDownBG)];
    tap.delegate = self;
    
    self.oldPwd.delegate = self;
    self.oldPwd.tag = 0;
    [self.oldPwd addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.pwd0.delegate = self;
    self.pwd0.tag = 1;
    [self.pwd0 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.pwd1.delegate = self;
    self.pwd1.tag = 2;
    [self.pwd1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboardByTouchDownBG
{
    // NSLog(@"dismissKeyboardByTouchDownBG");
    [self.oldPwd resignFirstResponder];
    [self.pwd0 resignFirstResponder];
    [self.pwd1 resignFirstResponder];
}

- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    if (textField.markedTextRange == nil && textField.text.length > 16) {
        textField.text = [textField.text substringToIndex:16];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 16 && string.length > range.length) {
        return NO;
    }
    
    return YES;
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

- (IBAction)cancelAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender {
    NSString *checkResult = [self checkInfo];
    if (checkResult) {
        NSLog(@"checkResult:%@", checkResult);
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"填写信息错误" description:checkResult type:TWMessageBarMessageTypeError];
    } else {
        [self modifyPasswordToServer];
    }
}

- (void)modifyPasswordToServer {
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    [manager.requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *path = @"User/UpdateUserInfo/password";
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSDictionary *paramDict = nil;
        paramDict = @{@"userID": USERID, @"password": self.pwd0.text};
        NSLog(@"path:%@\n paramDict:%@",path, paramDict);
        [manager POST:path parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"]) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSDictionary *userInfo = [defaults objectForKey:@"userInfo"];
                    NSMutableDictionary *newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
                    [newUserInfo setObject:self.pwd0.text forKey:@"loginPwd"];
                    [defaults setObject:newUserInfo forKey:@"userInfo"];
                    [defaults synchronize];
                    [self.parentViewController dismissViewControllerAnimated:YES completion:^(void){
                        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"密码修改成功"
                                                                       description:nil
                                                                              type:TWMessageBarMessageTypeSuccess
                                                                          callback:nil];
                    }];
                } else {
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"修改失败"
                                                                   description:@"请重新尝试"
                                                                          type:TWMessageBarMessageTypeError
                                                                      callback:nil];
                }
            }
            NSLog(@"modifyUserInfo Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"modifyUserInfo Error:%@", error);
        }];
    }
}

- (NSString *)checkInfo {
    NSString *pop = @"";
    NSString *pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"] objectForKey:@"loginPwd"];
    if (![self.oldPwd.text isEqualToString:pwd]) {
        pop = [pop stringByAppendingString:@"原始输入密码不正确\n"];
    } else {
        if (![self.pwd0.text isEqualToString:self.pwd1.text]) {
            pop = [pop stringByAppendingString:@"两次输入密码不一致\n"];
        } else if ([self.pwd0.text length] < 6) {
            pop = [pop stringByAppendingString:@"密码长度不足\n"];
        } else if ([self checkStrContainsChineseOrSpace:self.pwd0.text]) {
            pop = [pop stringByAppendingString:@"密码包含中文或空格\n"];
        }
    }
    return [pop isEqualToString:@""] ? nil : pop;
}

- (BOOL)checkStrContainsChineseOrSpace:(NSString *)text {
    if (text) {
        int length = [text length];
        
        for (int i=0; i<length; ++i)
        {
            NSRange range = NSMakeRange(i, 1);
            NSString *subString = [text substringWithRange:range];
            const char    *cString = [subString UTF8String];
            if (strlen(cString) == 3 || [subString isEqualToString:@" "])
            {
                return YES;
            }
        }
    }
    return NO;
}
@end
