//
//  XYFriendsNearByController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-31.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYFriendsNearByController.h"
#import "XYRoundView.h"

@interface XYFriendsNearByController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation XYFriendsNearByController

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
    
    self.scrollView.contentSize = self.imageView.frame.size;
    XYRoundView *round = [[XYRoundView alloc] initWithFrame:CGRectMake(200, 200, 50, 50)];
    
    UIImage *image = [UIImage imageNamed:@"5.JPG"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    [round addSubview:imageView];
    
    [self.imageView addSubview:round];
    
    // Do any additional setup after loading the view.
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

@end
