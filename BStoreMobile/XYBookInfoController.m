//
//  XYBookInfoController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-17.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYBookInfoController.h"
#import "XYBookInfoMainCell.h"
#import "UIKit+AFNetworking.h"
#import "XYCommentViewCell.h"
#import "XYRecBookCell.h"
#import "XYCollectionCell.h"
#import "XYUtil.h"
#import "XYStarRatedView.h"
#import "XYAutoLayoutLabel.h"

#define OFFSET2 20

@interface XYBookInfoController ()

enum BookInfoStatus {
    DETAILS, COMMENTS, RECOMMENDS
};

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property enum BookInfoStatus status;
@property (nonatomic, strong) UIView *toolView;
@property NSString *imageStr;
@property NSString *priceStr;
@property (nonatomic, strong) NSDictionary *outputDict;
@property (nonatomic, strong) NSDictionary *bookInfoDict;
@property (nonatomic, strong) NSArray *listComments;
@property (nonatomic, strong) NSArray *listRecommends;
@property (nonatomic, strong) NSArray *listOthers;
@property (nonatomic, strong) NSString *weibourl;

@end

@implementation XYBookInfoController

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
    [XYUtil setExtraCellLineHidden:self.tableView];
    [self prepareForToolView];
    [self getInfoFromSegue];
}

- (void)getInfoFromSegue
{
    if (self.titleStr && self.detailStr) {
        NSArray *array = [NSArray arrayWithObjects:@"cart",@"tobuy",@"paid", nil];
        for (NSInteger i=0; i<[array count]; i++) {
            NSArray *listItem = [self loadPlistFile:array[i] ofType:@"plist"];
            for (NSInteger j=0; j<[listItem count]; j++) {
                NSDictionary *rowDict = listItem[j];
                if ([[rowDict objectForKey:@"name"] isEqualToString:self.titleStr]) {
                    self.imageStr = [rowDict objectForKey:@"image"];
                    self.priceStr = @"￥";
                    self.priceStr = [self.priceStr stringByAppendingString:[rowDict objectForKey:@"price"]];
                    break;
                }
            }
        }
    }
    if (self.bookID) {
        [self loadBookDetailFromServer];
    }
    NSLog(@"getInfoFromSegue at XYBookInfoController");
}

// add ToolView with SegControl in section#1's header
- (void)prepareForToolView
{
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    NSArray *segItemsArray = [NSArray arrayWithObjects: @"详细信息", @"读者评论", @"相关推荐", nil];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
//    [segControl setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [segControl setTintColor:[UIColor lightGrayColor]];
    segControl.frame = CGRectMake(16, 8, 287, 29);
    segControl.selectedSegmentIndex = 0;
    self.status = DETAILS;
    [segControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.toolView addSubview:segControl];
    self.toolView.backgroundColor = [UIColor whiteColor];
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

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    if (self.status == DETAILS) {
        if (self.outputDict && self.bookInfoDict) {
            return 3;
        } else {
            return 0;
        }
    } else if(self.status == RECOMMENDS) {
        if (self.bookInfoDict) {
            if (self.listOthers && self.listRecommends) {
                return 2;
            } if ((self.listRecommends && !self.listOthers) || (self.listOthers && !self.listRecommends)) {
                return 1;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    } else {
        if (self.bookInfoDict && self.listComments) {
            return [self.listComments count];
        } else {
            return 0;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *mainCellID = @"BookInfoCellIdentifier";
        XYBookInfoMainCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellID];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYBookInfoMainCell" owner:nil options:nil];
            //第一个对象就是BookInfoCellIdentifier了（xib所列子控件中的最高父控件，BookInfoCellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        
        if (self.titleStr && self.detailStr) {
            cell.title.text = self.titleStr;
            cell.detail.text = self.detailStr;
            cell.coverImage.image = [UIImage imageNamed:self.imageStr];
        } else if (self.bookID) {
            if (self.bookInfoDict) {
                cell.title.text = self.bookInfoDict[@"title"];
                cell.detail.text = self.bookInfoDict[@"author"];
                if (self.weibourl) {
                    [cell.weiboBtn setHidden:NO];
                    [cell.weiboBtn setBackgroundImage:[UIImage imageNamed:@"sinalogo.png"] forState:UIControlStateNormal];
                    cell.weiboBtn.tag = [self.bookID intValue];
                    [cell.weiboBtn addTarget:self action:@selector(weiboButtonClicked:)forControlEvents:UIControlEventTouchUpInside];
                } else {
                    [cell.weiboBtn setHidden:YES];
                    CGFloat wx = cell.weiboBtn.frame.origin.x;
                    CGFloat wy = cell.weiboBtn.frame.origin.y;
                    CGFloat dw = cell.detail.frame.size.width + (cell.detail.frame.origin.x - wx);
                    CGFloat dh = cell.detail.frame.size.height;
                    [cell.detail setFrame:CGRectMake(wx, wy, dw, dh)];
                }
                int priceAtCent = [self.bookInfoDict[@"price"] intValue];
                self.priceStr = [XYUtil printMoneyAtCent:priceAtCent];
                
                NSNumber *cnt = self.bookInfoDict[@"countScore"];
                
                for (UIView *view in [cell.totScoreView subviews]) {
                    [view removeFromSuperview];
                }
                
                if ([cnt intValue] > 0) {
                    CGRect rect = CGRectMake(0, 0, cell.totScoreView.frame.size.width, cell.totScoreView.frame.size.height);
                    XYStarRatedView *starRateView = [[XYStarRatedView alloc] initWithFrame:rect numberOfStar:5 AtStatus:SHOWED];
                    starRateView.delegate = self;
                    [cell.totScoreView addSubview:starRateView];
                    
                    NSString *cntStr = [NSString stringWithFormat:@"(%@)", cnt];
                    cell.cntScore.text = cntStr;
                    
                    NSNumber *tot = self.bookInfoDict[@"sumScore"];
                    int avg = [tot intValue] / [cnt intValue];
                    CGPoint p = CGPointMake(avg * (rect.size.width / 5), rect.size.height);
                    [starRateView changeStarForegroundViewWithPoint:p];
                } else {
                    UILabel *lbl =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.totScoreView.frame.size.width, cell.totScoreView.frame.size.height)];
                    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:10];
                    lbl.font = font;
                    lbl.textColor = [UIColor lightGrayColor];
                    lbl.text = @"(暂无评分)";
                    [cell.totScoreView addSubview:lbl];
                    cell.cntScore.text = @"";
                }
                
                NSString *imagePath = self.bookInfoDict[@"coverimg"];
                __weak XYBookInfoMainCell *weakCell = cell;
                [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    weakCell.coverImage.image = image;
                    [weakCell setNeedsLayout];
                    [weakCell setNeedsDisplay];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    NSLog(@"Get Image from Server Error.");
                }];
                cell.buyButton.tag = [self.bookID intValue];
                [cell.buyButton addTarget:self action:@selector(buyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.toBuyButton.tag = [self.bookID intValue];
                [cell.toBuyButton addTarget:self action:@selector(toBuyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.navButton.tag = [self.bookID intValue];
                [cell.navButton addTarget:self action:@selector(navButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        [cell.buyButton setTitle:self.priceStr forState:UIControlStateNormal];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    switch (self.status) {
        case DETAILS: {
            NSString *detailCellID = @"BookDetailCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailCellID];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0: {
                    for (UIView *view in [cell.contentView subviews]) {
                        if ([view isKindOfClass:[UILabel class]]) {
                            [view removeFromSuperview];
                        }
                    }
                    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 100, 21)];
                    lbl.text = @"书籍简介";
                    lbl.textColor = [UIColor darkGrayColor];
                    [cell.contentView addSubview:lbl];
                    XYAutoLayoutLabel *textLabel = [[XYAutoLayoutLabel alloc] initWithFrame:CGRectMake(20, 28, 280, 110)];
                    textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                    textLabel.text = self.outputDict[@"brief"];
                    [cell.contentView addSubview:textLabel];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 1: {
                    for (UIView *view in [cell.contentView subviews]) {
                        if ([view isKindOfClass:[UILabel class]]) {
                            [view removeFromSuperview];
                        }
                    }
                    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 110, 21)];
                    lbl.text = @"主要作者简介";
                    lbl.textColor = [UIColor darkGrayColor];
                    [cell.contentView addSubview:lbl];
                    XYAutoLayoutLabel *textLabel = [[XYAutoLayoutLabel alloc] initWithFrame:CGRectMake(20, 28, 280, 110)];
                    textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                    textLabel.text = self.outputDict[@"authorinfo"];
                    [cell.contentView addSubview:textLabel];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 2: {
                    for (UIView *view in [cell.contentView subviews]) {
                        if ([view isKindOfClass:[UILabel class]]) {
                            [view removeFromSuperview];
                        }
                    }
                    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 110, 21)];
                    lbl.text = @"其它信息";
                    lbl.textColor = [UIColor darkGrayColor];
                    [cell.contentView addSubview:lbl];
                    
                    UILabel *lbl1_0 = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 48, 21)];
                    lbl1_0.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                    lbl1_0.text = @"ISBN";
                    lbl1_0.textColor = [UIColor darkGrayColor];
                    lbl1_0.textAlignment = NSTextAlignmentRight;
                    UILabel *lbl1_1 = [[UILabel alloc] initWithFrame:CGRectMake(85, 40, 215, 21)];
                    lbl1_1.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                    lbl1_1.text = self.bookInfoDict[@"ISBN"];
                    [cell.contentView addSubview:lbl1_0];
                    [cell.contentView addSubview:lbl1_1];
                    
                    UILabel *lbl2_0 = [[UILabel alloc] initWithFrame:CGRectMake(20, 69, 48, 21)];
                    lbl2_0.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                    lbl2_0.text = @"出版社";
                    lbl2_0.textColor = [UIColor darkGrayColor];
                    lbl2_0.textAlignment = NSTextAlignmentRight;
                    UILabel *lbl2_1 = [[UILabel alloc] initWithFrame:CGRectMake(85, 69, 215, 21)];
                    lbl2_1.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                    lbl2_1.text = self.outputDict[@"publisher"];
                    [cell.contentView addSubview:lbl2_0];
                    [cell.contentView addSubview:lbl2_1];
                                     
                    UILabel *lbl3_0 = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 48, 21)];
                    lbl3_0.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                    lbl3_0.text = @"出版日期";
                    lbl3_0.textColor = [UIColor darkGrayColor];
                    lbl3_0.textAlignment = NSTextAlignmentRight;
                    UILabel *lbl3_1 = [[UILabel alloc] initWithFrame:CGRectMake(85, 100, 215, 21)];
                    lbl3_1.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
                    lbl3_1.text = self.outputDict[@"pubdate"];
                    [cell.contentView addSubview:lbl3_0];
                    [cell.contentView addSubview:lbl3_1];
                                     
                    break;
                }
            }
            return cell;
        }
        case COMMENTS: {
            NSString *commentsCellID = @"BookCommentsCellIdentifier";
            XYCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentsCellID];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYCommentViewCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
            }
            NSDictionary *rowDict = [self.listComments objectAtIndex:indexPath.row];
            NSString *displayName = (rowDict[@"name"] == nil || [rowDict[@"name"] isEqualToString:@""]) ? rowDict[@"username"] : rowDict[@"name"];
            cell.uname.text = [NSString stringWithFormat:@"\"%@\"", displayName];
            cell.pubDate.text = rowDict[@"date"];
            cell.upCnt.text = [NSString stringWithFormat:@"%d", [rowDict[@"favorCount"] intValue]];
            cell.downCnt.text = [NSString stringWithFormat:@"%d", [rowDict[@"againstCount"] intValue]];
            cell.content.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
            cell.content.text = rowDict[@"content"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        case RECOMMENDS: {
            NSString *recommendsCellID = @"BookRecommendsCellIdentifier";
            XYRecBookCell *cell = (XYRecBookCell *)[tableView dequeueReusableCellWithIdentifier:recommendsCellID];
            if (cell == nil) {
                cell = [[XYRecBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recommendsCellID];
            }
            for (UIView *view in [cell.contentView subviews]) {
                if ([view isKindOfClass:[UILabel class]]) {
                    [view removeFromSuperview];
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.yoffset = OFFSET2;
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, cell.contentView.bounds.size.width, OFFSET2)];
            lbl.font = [UIFont systemFontOfSize:15.0f];
            if (indexPath.row == 0) {
                lbl.text = @"相关书籍";
            } else {
                lbl.text = @"周边产品";
            }
            [cell.contentView addSubview:lbl];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status == RECOMMENDS && indexPath.section == 1) {
        return 152.0f + OFFSET2;
    } else {
        if (self.status == DETAILS && indexPath.section == 1 && indexPath.row < 2) {
            NSString *key = indexPath.row == 0 ? @"brief" : @"authorinfo";
            XYAutoLayoutLabel *lbl = [[XYAutoLayoutLabel alloc] initWithFrame:CGRectMake(20, 28, 280, 110)];
            lbl.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
            lbl.text = self.outputDict[key];
            return lbl.frame.origin.y + lbl.frame.size.height + 10.0f;
        } else if (self.status == COMMENTS && indexPath.section == 1) {
            XYAutoLayoutLabel *lbl = [[XYAutoLayoutLabel alloc] initWithFrame:CGRectMake(20, 44, 280, 20)];
            lbl.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
            NSDictionary *rowDict = self.listComments[indexPath.row];
            lbl.text = rowDict[@"content"];
            return lbl.frame.origin.y + lbl.frame.size.height + 10.0f;
        } else {
            return  143.0f;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 45.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        // 每次reload tableview时，均要调用，因此不能在此处alloc/init toolbar，应当将toolbar作为一个成员变量，只初始化一次
        return self.toolView;
    }
    return nil;
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.bookInfoDict && self.status == RECOMMENDS) {
        if (collectionView.tag == 0) {
            return self.listRecommends == nil ? 0 : [self.listRecommends count];
        } else {
            return self.listOthers == nil ? 0 : [self.listOthers count];
        }
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 0) {
        // NSLog(@"collectionView:cellForItemAtIndexPath");
        XYCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYCollectionCell" owner:nil options:nil];
            //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        // configure collection view cell
        NSDictionary *rowDict = [self.listRecommends objectAtIndex:indexPath.row];
        cell.title.text = rowDict[@"title"];
        cell.detail.text = rowDict[@"author"];
        NSNumber *num = rowDict[@"bookID"];
        cell.title.tag = [num integerValue];
        NSString *imagePath = rowDict[@"coverimg"];
        __weak XYCollectionCell *weakCell = cell;
        [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakCell.coverImage.image = image;
            [weakCell setNeedsLayout];
            [weakCell setNeedsDisplay];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Get Image from Server Error.");
        }];
        return cell;
    } else {
        // NSLog(@"collectionView:cellForItemAtIndexPath");
        XYCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            // XYSaleItemCell.xib as NibName
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYCollectionCell" owner:nil options:nil];
            //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
            cell = [nib objectAtIndex:0];
        }
        // configure collection view cell
        if (self.listOthers) {
            NSDictionary *rowDict = [self.listOthers objectAtIndex:indexPath.row];
            cell.title.text = rowDict[@"itemName"];
            cell.detail.text = rowDict[@"type"];
            NSString *imagePath = rowDict[@"image"];
//            cell.coverImage.image = [UIImage imageNamed:imagePath];
            __weak XYCollectionCell *weakCell = cell;
            [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakCell.coverImage.image = image;
                [weakCell setNeedsLayout];
                [weakCell setNeedsDisplay];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"Get Image from Server Error.");
            }];
        }
        return cell;
    }
}

// tell the delegate the table view is aobut to draw a cell for a pariticular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(XYRecBookCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0 && self.status == RECOMMENDS) {
        NSInteger tag = indexPath.row;
        if (indexPath.row == 0) {
            if (!self.listRecommends) {
                tag = 1;
            }
        }
        [cell setCollectionViewDataSourceDelegate:self index:tag];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status == RECOMMENDS) {
        if (collectionView.tag == 0) {
            XYCollectionCell * cell = (XYCollectionCell *) [collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                // pushViewController
                UIStoryboard *mainsb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                XYBookInfoController *bookInfoController = [mainsb instantiateViewControllerWithIdentifier:@"BookInfo"];
                bookInfoController.bookID = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:cell.title.tag]];
                [self.navigationController pushViewController:bookInfoController animated:YES];
            }
        } else {
            if (self.listOthers) {
                NSDictionary *rowDict = [self.listOthers objectAtIndex:indexPath.row];
                NSString *url = rowDict[@"url"];
                NSDictionary *valueDict = @{@"url": url};
                [self performSegueWithIdentifier:@"WebView" sender:valueDict];
            }
        }
    }
}

- (IBAction)valueChanged:(id)sender
{
    NSInteger index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    switch (index) {
        case 0:
            // NSLog(@"Seg Control valued changed to 0");
            self.status = DETAILS;
            if (self.bookID) {
                [self loadBookDetailFromServer];
            }
            break;
        case 1:
            // NSLog(@"Seg Control valued changed to 1");
            self.status = COMMENTS;
            if (self.bookID) {
                [self loadBookCommentsFromServer];
            }
            break;
        case 2:
            // NSLog(@"Seg Control valued changed to 2");
            self.status = RECOMMENDS;
            if (self.bookID) {
                [self loadBookRecommendsFromServer];
            }
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (NSArray *) loadPlistFile:(NSString *)path ofType:(NSString *)type {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:path ofType:type];
    
    // 获取属性列表文件中的全部数据
    NSArray *listItem = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSLog(@"XYBookInfoController loadPlistFile from %@.%@ %lu",path, type,(unsigned long)[listItem count]);
    return listItem;
}

- (NSArray *) loadOthersFile
{
    return [self loadPlistFile:@"others" ofType:@"plist"];
}

- (NSArray *) loadWeiboFile
{
    return [self loadPlistFile:@"weibo" ofType:@"plist"];
}

- (void) loadBookDetailFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
//    NSString *path = [@"BookDetail/" stringByAppendingString:self.bookID];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"BookDetailV2?userID=%@&bookID=%@", USERID, self.bookID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *tmp = (NSDictionary *)responseObject;
            if (tmp) {
                self.bookInfoDict = tmp[@"bookinfo"];
                self.outputDict = tmp[@"details"];
                NSString *tmpStr = self.bookInfoDict[@"weiboURL"];
                if (tmpStr && ![tmpStr isEqualToString:@""] && ![tmpStr isEqualToString:@" "]) {
                    self.weibourl = tmpStr;
                }
//                NSArray *others = [self loadOthersFile];
//                if (others) {
//                    for (NSDictionary *rowDict in others) {
//                        NSString *key = self.bookInfoDict[@"title"];
//                        if (rowDict[key]) {
//                            self.listOthers = rowDict[key];
//                            break;
//                        }
//                    }
//                }
//                NSArray *weibos = [self loadWeiboFile];
//                if (weibos) {
//                    for (NSDictionary *rowDict in weibos) {
//                        NSString *key = self.bookInfoDict[@"author"];
//                        if (rowDict[key]) {
//                            self.weibourl = rowDict[key];
//                            break;
//                        }
//                    }
//                }
            }
            NSLog(@"loadBookDetailFromServer Success");
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadBookDetailFromServer Error:%@", error);
        }];
    }
}

- (void) loadBookCommentsFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"BookComment/" stringByAppendingString:self.bookID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *tmp = (NSDictionary *)responseObject;
        if (tmp) {
            self.listComments = tmp[@"comments"];
        }
        NSLog(@"loadBookCommentsFromServer Success");
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadBookCommentsFromServer Error:%@", error);
    }];
}

- (void) loadBookRecommendsFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"BookRelatedV3?userID=%@&bookID=%@", USERID, self.bookID];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *tmpDict = (NSDictionary *)responseObject;
            self.listRecommends = tmpDict[@"bookrelated"];
            self.listOthers = tmpDict[@"others"];
            if ([self.listRecommends count] == 0) {
                self.listRecommends = nil;
            }
            if ([self.listOthers count] == 0) {
                self.listOthers = nil;
            }
            NSLog(@"loadBookRecommendsFromServer Success");
            [self.tableView reloadData];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loadBookRecommendsFromServer Error:%@", error);
        }];
    }
}

- (IBAction)buyButtonClicked:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    if (self.bookID && tag > 0) {
        NSLog(@"Add bookID #%@ amount:1", self.bookID);
        [self addOneItemToCart:tag];
    }
}

- (IBAction)weiboButtonClicked:(id)sender
{
    NSLog(@"Weibo View Clicked");
    if (self.weibourl) {
        NSDictionary *valueDict = @{@"url": self.weibourl};
        [self performSegueWithIdentifier:@"WebView" sender:valueDict];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WebView"]) {
        UIViewController *dest = segue.destinationViewController;
        NSDictionary *dic = sender;
        if (dic) {
            for (NSString *key in dic) {
                NSLog(@"%@, %@", key, dic[key]);
                [dest setValue:dic[key] forKey:key];
            }
        }
    }
}

- (void) addOneItemToCart:(NSInteger)bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/AddCart?userID=%@&bookID=%@&amount=1", USERID, [NSNumber numberWithInteger:bookID]];
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
}

- (IBAction)toBuyButtonClicked:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    if (self.bookID && tag > 0) {
        NSLog(@"Add bookID #%@ To Wishlist", self.bookID);
        [self addItemToWishlist:tag];
    }
}

- (void) addItemToWishlist:(NSInteger)bookID
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *USERID = [XYUtil getUserID];
    if (USERID) {
        NSString *path = [NSString stringWithFormat:@"User/AddWishlist?userID=%@&bookID=%@", USERID, [NSNumber numberWithInteger:bookID]];
        NSLog(@"path:%@",path);
        [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *retDict = (NSDictionary *)responseObject;
            if (retDict && retDict[@"message"]) {
                NSLog(@"message: %@", retDict[@"message"]);
                if ([retDict[@"message"] isEqualToString:@"successful"] || [retDict[@"message"] isEqualToString:@"already exist"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加到心愿单" message:@"该商品已成功添加到心愿单" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
            }
            NSLog(@"addItemToWishlist Success");
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"addItemToWishlist Error:%@", error);
        }];
    }
}

- (IBAction)navButtonClicked:(id)sender
{
    [[XYLocationManager sharedManager] showNavigationModal];
}

@end
