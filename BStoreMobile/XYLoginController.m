//
//  XYLoginController.m
//  BStoreMobile
//
//  Created by Julie on 14-8-31.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYLoginController.h"
#import "XYAppDelegate.h"
#import "XYUtil.h"

@interface XYLoginController ()
@property (weak, nonatomic) IBOutlet UITextField *loginName;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
- (IBAction)forgetPwdAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)loginErrAction:(id)sender;
- (IBAction)signUpAction:(id)sender;


@end

@implementation XYLoginController

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
    [self.view addGestureRecognizer:tap];
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

- (IBAction)forgetPwdAction:(id)sender {
}

- (IBAction)loginAction:(id)sender {
    NSString *name = self.loginName.text;
    NSString *pwd = self.pwd.text;
    
    [self confirmLoginInfo:name AtPassword:pwd];
    
}

- (void)writeLoginName:(NSString* )name AtPwd:(NSString* )pwd WithUserID:(NSString* )userID {
    // 获取注册的值
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userList = @{@"loginName": name, @"loginPwd": pwd, @"userID": userID};
    [defaults setObject:userList forKey:@"userList"];
    [defaults synchronize];
}

- (IBAction)loginErrAction:(id)sender {
}

- (IBAction)signUpAction:(id)sender {
}

- (void)dismissKeyboardByTouchDownBG
{
    [self.loginName resignFirstResponder];
    [self.pwd resignFirstResponder];
}

-(void) confirmLoginInfo:(NSString *)loginName AtPassword:(NSString *)pwd
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    [manager.requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *path = @"User/Login";
    NSLog(@"path:%@",path);
    NSDictionary *params = @{@"username": loginName, @"password": pwd};
    [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"userID"]) {
            NSNumber *userID = retDict[@"userID"];
            if ([userID intValue] <= 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户名或密码错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } else {
                NSString *uid = [NSString stringWithFormat:@"%@", userID];
                [self writeLoginName:loginName AtPwd:pwd WithUserID:uid];
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                UITabBarController *tabBarController = (UITabBarController *)[storyBoard instantiateViewControllerWithIdentifier:@"tabBarController"];
                
                XYAppDelegate *appDelegateTemp = (XYAppDelegate *) [[UIApplication sharedApplication]delegate];
                appDelegateTemp.window.rootViewController = tabBarController;
            }
        }
        NSLog(@"confirmLoginInfo Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"confirmLoginInfo Error:%@", error);
    }];
}

@end
