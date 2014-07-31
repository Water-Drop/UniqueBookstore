//
//  XYFriendsNearByController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-31.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYFriendsNearByController.h"
#import "XYRoundControl.h"
#import "CustomIOS7AlertView.h"
#import "XYUtil.h"
#import "XYRoundView.h"

@interface XYFriendsNearByController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *infoArray;
@property (nonatomic, strong) NSMutableArray *rectArray;

@property (nonatomic, strong) CustomIOS7AlertView *alertView;

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
    
    // Do any additional setup after loading the view.
    
    self.scrollView.contentSize = self.imageView.frame.size;
    
    [self prepareForData];
    
    for (int i=0; i<5; i++) {
        NSDictionary *rowDict = self.rectArray[i];
        float x = [rowDict[@"x"] floatValue];
        float y = [rowDict[@"y"] floatValue];
        float width = [rowDict[@"width"] floatValue];
        float height = [rowDict[@"height"] floatValue];
        NSLog(@"%f, %f, %f, %f", x, y, width, height);
        CGRect rect = CGRectMake(x, y, width, height);
        XYRoundControl *round = [[XYRoundControl alloc] initWithFrame:rect];
        round.tag = i;
        round.range = 5;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"headImg_%d.jpg",i % 5]];
        [round addSubview:imgView];
        [round addTarget:self action:@selector(clickForInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:round];
    }
}

- (void)prepareForData
{
    self.rectArray = [[NSMutableArray alloc] init];
    self.infoArray = [[NSMutableArray alloc] init];
    
    [self.rectArray addObject:@{@"x": [NSNumber numberWithFloat:100], @"y": [NSNumber numberWithFloat:100], @"width": [NSNumber numberWithFloat:50], @"height": [NSNumber numberWithFloat:50]}];
    [self.infoArray addObject:@{@"favorite": @"计算机", @"username": @"忘.惑", @"distance": @"0.5米"}];
    
    [self.rectArray addObject:@{@"x": [NSNumber numberWithFloat:200], @"y": [NSNumber numberWithFloat:200], @"width": [NSNumber numberWithFloat:50], @"height": [NSNumber numberWithFloat:50]}];
    [self.infoArray addObject:@{@"favorite": @"儿童文学", @"username": @"小鲸鱼", @"distance": @"1米"}];
    
    [self.rectArray addObject:@{@"x": [NSNumber numberWithFloat:230], @"y": [NSNumber numberWithFloat:20], @"width": [NSNumber numberWithFloat:50], @"height": [NSNumber numberWithFloat:50]}];
    [self.infoArray addObject:@{@"favorite": @"计算机", @"username": @"非天离巢", @"distance": @"1米"}];
    
    [self.rectArray addObject:@{@"x": [NSNumber numberWithFloat:320], @"y": [NSNumber numberWithFloat:60], @"width": [NSNumber numberWithFloat:50], @"height": [NSNumber numberWithFloat:50]}];
    [self.infoArray addObject:@{@"favorite": @"侦探小说", @"username": @"豌豆", @"distance": @"1米"}];
    
    [self.rectArray addObject:@{@"x": [NSNumber numberWithFloat:580], @"y": [NSNumber numberWithFloat:100], @"width": [NSNumber numberWithFloat:50], @"height": [NSNumber numberWithFloat:50]}];
    [self.infoArray addObject:@{@"favorite": @"历史政治", @"username": @"逍遥南华", @"distance": @"1米"}];
}

- (void)clickForInfo:(id)sender
{
    NSInteger tag = ((XYRoundControl *)sender).tag;
    
    NSLog(@"clickForInfo:%d", tag);
    
    // Here we need to pass a full frame
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createContentView:tag]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:nil]];
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
    
    self.alertView = alertView;
    
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    [alertView close];
}

- (UIView *)createContentView:(NSInteger)tag
{
    NSDictionary *rowDict = self.infoArray[tag];
    if (rowDict) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 150)];
        
        //    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 270, 180)];
        //    [imageView setImage:[UIImage imageNamed:@"demo"]];
        //    [demoView addSubview:imageView];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:17];
        UIFont *font1 = [UIFont fontWithName:@"Helvetica Neue" size:15];
        UIFont *font2 = [UIFont fontWithName:@"Helvetica Neue" size:12];
        
        XYRoundView *round = [[XYRoundView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        round.range = 5;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"headImg_%d.jpg",tag % 5]];
        [round addSubview:imgView];
        
        UILabel *lbl0 = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 160, 21)];
        lbl0.text = rowDict[@"username"];
        lbl0.font = font;
        UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(25, 60, 195, 21)];
        lbl1.text = [NSString stringWithFormat:@"兴趣:%@", rowDict[@"favorite"]];
        lbl1.font = font1;
        UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(25, 86, 195, 21)];
        lbl2.text = [NSString stringWithFormat:@"距离:%@", rowDict[@"distance"]];
        lbl2.font = font1;
        
        UIButton *btn0 = [[UIButton alloc] initWithFrame:CGRectMake(200, 15, 70, 30)];
        UIColor *defaultColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [btn0 setTitle:@"加为好友" forState:UIControlStateNormal];
        [btn0 setTitleColor:defaultColor forState:UIControlStateNormal];
        [btn0 setTintColor:defaultColor];
        [btn0.titleLabel setFont:font2];
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(200, 60, 70, 30)];
        [btn1 setTitle:@"去找他(她)" forState:UIControlStateNormal];
        [btn1 setTitleColor:defaultColor forState:UIControlStateNormal];
        [btn1 setTintColor:defaultColor];
        [btn1.titleLabel setFont:font2];
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(200, 105, 70, 30)];
        [btn2 setTitle:@"取消" forState:UIControlStateNormal];
        [btn2 setTitleColor:defaultColor forState:UIControlStateNormal];
        [btn2 setTintColor:defaultColor];
        [btn2.titleLabel setFont:font2];
        [btn2 addTarget:self action:@selector(closeAlertView:) forControlEvents:UIControlEventTouchUpInside];
        
        [XYUtil showButtonBorder:btn0];
        [XYUtil showButtonBorder:btn1];
        [XYUtil showButtonBorder:btn2];
        
        [view addSubview:round];
        [view addSubview:lbl0];
        [view addSubview:lbl1];
        [view addSubview:lbl2];
        [view addSubview:btn0];
        [view addSubview:btn1];
        [view addSubview:btn2];
        
        return view;
    }
    return nil;
}

- (void)closeAlertView:(id)sender
{
    if (self.alertView) {
        [self.alertView close];
    }
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
