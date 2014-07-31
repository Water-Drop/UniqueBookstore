//
//  XYBookOverlay.m
//  BStoreMobile
//
//  Created by Jiguang on 7/25/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYBookOverlay.h"
#import "UIKit+AFNetworking.h"
#import "XYUtil.h"
#import "UIERealTimeBlurView.h"

@implementation XYBookOverlay

@synthesize controller;

- (id)initWithId:(NSString*)key
{
    self = [super init];
    bookId = key;
    
    cmtCount = 0;
    
    btns = [[NSBundle mainBundle] loadNibNamed:@"XYCameraButtons" owner:nil options:nil][0];
    
    [btns.infoButton addTarget:self action:@selector(bookInfoAction) forControlEvents:UIControlEventTouchUpInside];
    [btns.cartButton addTarget:self action:@selector(bookCartAction) forControlEvents:UIControlEventTouchUpInside];
    
    info = [[UIButton alloc] init];
    [info addTarget:self action:@selector(bookInfoAction) forControlEvents:UIControlEventTouchUpInside];
    [self styleBtn:info];
    
    [info setImage:[UIImage imageNamed:@"bookmark-50.png"] forState:UIControlStateNormal];
    
    comments = [[UILabel alloc] init];
    comment1 = [[UILabel alloc] init];
    comment2 = [[UILabel alloc] init];
    comment3 = [[UILabel alloc] init];
    
    [self styleComment:comment1];
    [self styleComment:comment2];
    [self styleComment:comment3];
    
//    UIImage *bubble = [[UIImage imageNamed:@"1.png"]
//                       stretchableImageWithLeftCapWidth:41 topCapHeight:14];
    
    UIImage *bubble = [[UIImage imageNamed:@"mbubble6.png"]
                       stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    image1 = [[UIImageView alloc] initWithImage:bubble];
    image2 = [[UIImageView alloc] initWithImage:bubble];
    image3 = [[UIImageView alloc] initWithImage:bubble];
    
//    UIImage *avatar = [UIImage imageNamed:@"talk-50.png"];
    
    int index = (int)(rand()%5);
    
    avatar1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat: @"headImg_%d.jpg", index]]];
    avatar2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat: @"headImg_%d.jpg", (index+2)%5]]];
    avatar3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat: @"headImg_%d.jpg", (index+4)%5]]];
    
    [self styleAvatar:avatar1];
    [self styleAvatar:avatar2];
    [self styleAvatar:avatar3];
    
    
    [self loadBookInfoFromServer];
    [self loadBookCommentsFromServer];
    
    return self;
}

- (void)hide
{
    info.hidden = YES;
    btns.hidden = YES;
    
    image1.hidden = YES;
    image2.hidden = YES;
    image3.hidden = YES;
    
    avatar1.hidden = YES;
    avatar2.hidden = YES;
    avatar3.hidden = YES;
    
    comment1.hidden = YES;
    comment2.hidden = YES;
    comment3.hidden = YES;
}

- (void)refresh:(UIView*)view mvp:(QCAR::Matrix44F)matrix image:(const QCAR::ImageTarget&)image
{
//    info.hidden = NO;
//    buy.hidden = NO;
//    price.hidden = NO;
    
//    btns.hidden = NO;
    
    // original image width and height
    float iw = image.getSize().data[0];
    float ih = image.getSize().data[1];
    
//    NSLog(@"Trackable size: %f %f", iw, ih);
    
    // viewport width and height
    float vw = [view bounds].size.width;
    float vh = [view bounds].size.height;
    
    // topleft point position
    float tw = - matrix.data[3] * iw / 2 + matrix.data[7] * ih / 2 + matrix.data[15];
    float tx = ( - matrix.data[0] * iw / 2 + matrix.data[4] * ih / 2 + matrix.data[12] ) / tw;
    float ty = ( - matrix.data[1] * iw / 2 + matrix.data[5] * ih / 2 + matrix.data[13] ) / tw;
    
    // bottomright point position
    float bw = matrix.data[3] * iw / 2 - matrix.data[7] * ih / 2 + matrix.data[15];
    float bx = ( matrix.data[0] * iw / 2 - matrix.data[4] * ih / 2 + matrix.data[12] ) / bw;
    float by = ( matrix.data[1] * iw / 2 - matrix.data[5] * ih / 2 + matrix.data[13] ) / bw;
    
    // center point position
//    float cx = matrix.data[12]/matrix.data[15];
//    float cy = matrix.data[13]/matrix.data[15];
    
    // true topleft point position
    float txt = vw/2*(tx+1);
    float tyt = vh-vh/2*(ty+1);
    
    // true bottomright point position
    float bxt = vw/2*(bx+1);
    float byt = vh-vh/2*(by+1);
    
    if (bxt-txt > 100 && byt-tyt > 194) {
        if (cmtCount > 0) {
            image1.hidden = NO;
            avatar1.hidden = NO;
            comment1.hidden = NO;
        }
        if (cmtCount > 1) {
            image2.hidden = NO;
            avatar2.hidden = NO;
            comment2.hidden = NO;
        }
        if (cmtCount > 2) {
            image3.hidden = NO;
            avatar3.hidden = NO;
            comment3.hidden = NO;
        }
    }
    
    if (bxt - txt > 80) {
        btns.hidden = NO;
        CGRect btnsBound = CGRectMake(bxt-92, byt-70, 92, 70);
        btns.frame = btnsBound;
        [view addSubview:btns];
        [view bringSubviewToFront:btns];
    } else {
        info.hidden = NO;
        CGRect infoBound = CGRectMake(bxt-34, byt-34, 34, 34);
        info.frame = infoBound;
        [view addSubview:info];
        [view bringSubviewToFront:info];
    }
    
    if (cmtCount > 0) {
        //
        [comment1 sizeToFit];
        float cmtw1 = bxt-txt-36-18 > comment1.frame.size.width ? comment1.frame.size.width : bxt-txt-36-18;
        CGRect lblBound1 = CGRectMake(txt+36+12, tyt, cmtw1, 40);
        CGRect cmtBound1 = CGRectMake(txt+36, tyt, cmtw1+18, 40);
        CGRect avaBound1 = CGRectMake(txt+4, tyt+4, 32, 32);
        image1.frame = cmtBound1;
        avatar1.frame = avaBound1;
        comment1.frame = lblBound1;
        [view addSubview:image1];
        [view bringSubviewToFront:image1];
        [view addSubview:avatar1];
        [view bringSubviewToFront:avatar1];
        [view addSubview:comment1];
        [view bringSubviewToFront:comment1];
    }
    if (cmtCount > 1) {
        //
        [comment2 sizeToFit];
        float cmtw2 = bxt-txt-36-18 > comment2.frame.size.width ? comment2.frame.size.width : bxt-txt-36-18;
        CGRect lblBound2 = CGRectMake(txt+36+12, tyt+42, cmtw2, 40);
        CGRect cmtBound2 = CGRectMake(txt+36, tyt+42, cmtw2+18, 40);
        CGRect avaBound2 = CGRectMake(txt+4, tyt+46, 32, 32);
        [view addSubview:image2];
        image2.frame = cmtBound2;
        avatar2.frame = avaBound2;
        comment2.frame = lblBound2;
        [view bringSubviewToFront:image2];
        [view addSubview:avatar2];
        [view bringSubviewToFront:avatar2];
        [view addSubview:comment2];
        [view bringSubviewToFront:comment2];
    }
    if (cmtCount > 2) {
        //
        [comment3 sizeToFit];
        float cmtw3 = bxt-txt-36-18 > comment3.frame.size.width ? comment3.frame.size.width : bxt-txt-36-18;
        CGRect lblBound3 = CGRectMake(txt+36+12, tyt+84, cmtw3, 40);
        CGRect cmtBound3 = CGRectMake(txt+36, tyt+84, cmtw3+18, 40);
        CGRect avaBound3 = CGRectMake(txt+4, tyt+88, 32, 32);
        image3.frame = cmtBound3;
        avatar3.frame = avaBound3;
        comment3.frame = lblBound3;
        [view addSubview:image3];
        [view bringSubviewToFront:image3];
        [view addSubview:avatar3];
        [view bringSubviewToFront:avatar3];
        [view addSubview:comment3];
        [view bringSubviewToFront:comment3];
    }
    
}

- (void)styleBtn:(UIButton*)btn
{
    [btn setImageEdgeInsets:UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f)];
    [btn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    btn.layer.borderWidth = 1.0f;
    btn.layer.cornerRadius = 5.0f;
    btn.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    btn.layer.masksToBounds = YES;
    btn.layer.backgroundColor = [UIColor whiteColor].CGColor;
    btn.layer.opacity = 0.65f;
}

- (void)styleAvatar:(UIImageView*)avatar
{
    [avatar.layer setMasksToBounds:YES];
    [avatar.layer setCornerRadius:5.0f];
    [avatar.layer setOpacity:0.85f];
    [avatar.layer setBackgroundColor:[UIColor whiteColor].CGColor];
}

- (void)styleComment:(UILabel*)comment
{
    comment.font = [UIFont systemFontOfSize:12];
    [comment setNumberOfLines:1];
}

- (void)bookInfoAction
{
    NSDictionary *dic = @{@"bookID": bookId};
    [controller performSegueWithIdentifier:@"BookDetail" sender:dic];
}

- (void)bookCartAction
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [NSString stringWithFormat:@"User/AddCart?userID=%@&bookID=%@&amount=1", USERID, bookId];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *retDict = (NSDictionary *)responseObject;
        if (retDict && retDict[@"message"]) {
            NSLog(@"message: %@", retDict[@"message"]);
            if ([retDict[@"message"] isEqualToString:@"successful"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加到购物车" message:@"该商品已成功添加到购物车" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }
        NSLog(@"addOneItemToCart Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"addOneItemToCart Error:%@", error);
    }];
}

- (void)loadBookInfoFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"BookDetail/" stringByAppendingString:bookId];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *tmp = (NSDictionary *)responseObject;
        if (tmp) {
            bookInfoDict = tmp[@"bookinfo"];
        }
        // set labels
        [btns.price setText:[NSString stringWithFormat:@"%@", [XYUtil printMoneyAtCent:[bookInfoDict[@"price"] intValue]]]];
        
        NSLog(@"loadBookDetailFromServer Success");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadBookDetailFromServer Error:%@", error);
    }];
}

- (void)loadBookCommentsFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"BookComment/" stringByAppendingString:bookId];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *tmp = (NSDictionary *)responseObject;
        if (tmp) {
            listComments = tmp[@"comments"];
            cmtCount = listComments.count;
            
            if (cmtCount > 0) {
                [comment1 setText:listComments[0][@"content"]];
            }
            if (cmtCount > 1) {
                [comment2 setText:listComments[1][@"content"]];
            }
            if (cmtCount > 2) {
                [comment3 setText:listComments[2][@"content"]];
            }
        }
        NSLog(@"loadBookCommentsFromServer Success");
    
        // set labels
    
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadBookCommentsFromServer Error:%@", error);
    }];
}



@end
