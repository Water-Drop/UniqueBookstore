//
//  XYSecurityInfoController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-10.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYSecurityInfoController.h"
#import "XYGenderChangeController.h"

@interface XYSecurityInfoController ()
@property (weak, nonatomic) IBOutlet UILabel *isToPublic;

@end

@implementation XYSecurityInfoController

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
    [self loadSecurityInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self loadSecurityInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSecurityInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.isToPublic.text = [[defaults objectForKey:@"userInfo"] objectForKey:@"isToPublic"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"locationChange"]) {
        UINavigationController *nav = (UINavigationController *)segue.destinationViewController;
        UIViewController *dest = nav.viewControllers[0];
        NSDictionary *valueDict = @{@"gender": self.isToPublic.text, @"status": [NSNumber numberWithInteger:LOCATION]};
        for (NSString *key in valueDict) {
            NSLog(@"%@, %@", key, valueDict[key]);
            [dest setValue:valueDict[key] forKey:key];
        }
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
