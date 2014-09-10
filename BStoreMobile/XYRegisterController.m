//
//  XYRegisterController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-9.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYRegisterController.h"
#import "XYUtil.h"
#import "XYAppDelegate.h"

@interface XYRegisterController ()
@property (weak, nonatomic) IBOutlet UITextField *uname;
@property (weak, nonatomic) IBOutlet UITextField *pwd0;
@property (weak, nonatomic) IBOutlet UITextField *pwd1;
- (IBAction)cancelAction:(id)sender;
- (IBAction)signUpAction:(id)sender;

@end

@implementation XYRegisterController

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
    
    self.uname.delegate = self;
    self.uname.tag = 0;
    [self.uname addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    [self.uname resignFirstResponder];
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

- (IBAction)signUpAction:(id)sender {
    NSString *checkResult = [self checkInfo];
    if (checkResult) {
        NSLog(@"checkResult:%@", checkResult);
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"注册信息填写错误" description:checkResult type:TWMessageBarMessageTypeError];
    } else {
        [self registerUserInfoToServer];
    }
}

- (void)registerUserInfoToServer {
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    [manager.requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *path = [NSString stringWithFormat:@"User/Register"];
    NSDictionary *paramDict = @{@"username": self.uname.text, @"password": self.pwd0.text, @"name": @"", @"phonenumber": @"", @"email": @""};
    NSLog(@"path:%@\n paramDict:%@",path, paramDict);
    [manager POST:path parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"message"]) {
            NSLog(@"message: %@", retDict[@"message"]);
            if ([retDict[@"message"] isEqualToString:@"successful"]) {
                NSNumber *userID = retDict[@"userID"];
                NSString *uid = [NSString stringWithFormat:@"%@", userID];
                [self loginAction:uid];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"注册成功" description:[NSString stringWithFormat:@"%@ 欢迎光临新知书店", self.uname.text] type:TWMessageBarMessageTypeSuccess];
            }
        } else {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"注册失败" description:@"请重新检查注册信息" type:TWMessageBarMessageTypeError];
        }
        NSLog(@"RegisterUserInfoToServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"RegisterUserInfoToServer Error:%@", error);
    }];
}

- (void)loginAction:(NSString *)userID {
    [self login:userID];
    
    XYAppDelegate *appDelegateTemp = (XYAppDelegate *) [[UIApplication sharedApplication]delegate];
    appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]] instantiateInitialViewController];;
    
    [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
}
- (void)login:(NSString *)userID {
    NSString *name = self.uname.text;
    NSString *pwd = self.pwd0.text;
    [self writeLoginName:name AtPwd:pwd WithUserID:userID];
}

- (void)writeLoginName:(NSString* )name AtPwd:(NSString* )pwd WithUserID:(NSString* )userID {
    // 获取注册的值
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = @{@"loginName": name, @"loginPwd": pwd, @"userID": userID, @"isToPublic": @"公开"};
    [defaults setObject:userInfo forKey:@"userInfo"];
    [defaults synchronize];
}


- (NSString *)checkInfo {
    NSString *pop = @"";
    if ([self.uname.text length] < 4) {
        pop = [pop stringByAppendingString:@"用户名长度不足\n"];
    } else if ([self checkStrContainsChineseOrSpace:self.uname.text]) {
            pop = [pop stringByAppendingString:@"用户名包含中文或空格\n"];
    }
    if (![self.pwd0.text isEqualToString:self.pwd1.text]) {
        pop = [pop stringByAppendingString:@"两次输入密码不一致\n"];
    } else if ([self.pwd0.text length] < 6) {
            pop = [pop stringByAppendingString:@"密码长度不足\n"];
    } else if ([self checkStrContainsChineseOrSpace:self.pwd0.text]) {
            pop = [pop stringByAppendingString:@"密码包含中文或空格\n"];
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
