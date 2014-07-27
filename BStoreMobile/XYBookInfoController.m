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

@end

@implementation XYBookInfoController

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

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
    [self setExtraCellLineHidden:self.tableView];
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
        if (self.bookInfoDict && self.listRecommends) {
            return 1;
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
                int priceAtCent = [self.bookInfoDict[@"price"] intValue];
                int price0 = priceAtCent / 100;
                int price1 = priceAtCent % 100;
                self.priceStr = [NSString stringWithFormat:@"￥%d.%d", price0, price1];
                
                NSString *imagePath = self.bookInfoDict[@"coverimg"];
                __weak XYBookInfoMainCell *weakCell = cell;
                [cell.coverImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imagePath]] placeholderImage:[UIImage imageNamed:@"book.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    weakCell.coverImage.image = image;
                    [weakCell setNeedsLayout];
                    [weakCell setNeedsDisplay];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    NSLog(@"Get Image from Server Error.");
                }];
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
                    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 100, 21)];
                    lbl.text = @"书籍简介";
                    lbl.textColor = [UIColor darkGrayColor];
                    [cell.contentView addSubview:lbl];
                    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 28, 280, 110)];
                    textView.text = self.outputDict[@"brief"];
                    textView.editable = NO;
                    textView.scrollEnabled = YES;
                    [cell.contentView addSubview:textView];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 1: {
                    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 110, 21)];
                    lbl.text = @"主要作者简介";
                    lbl.textColor = [UIColor darkGrayColor];
                    [cell.contentView addSubview:lbl];
                    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 28, 280, 110)];
                    textView.text = self.outputDict[@"authorinfo"];
                    textView.editable = NO;
                    textView.scrollEnabled = YES;
                    [cell.contentView addSubview:textView];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 2: {
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
            cell.uname.text = [NSString stringWithFormat:@"\"%@\"", rowDict[@"username"]];
            cell.pubDate.text = rowDict[@"date"];
            cell.upCnt.text = [NSString stringWithFormat:@"%d", [rowDict[@"favorCount"] intValue]];
            cell.downCnt.text = [NSString stringWithFormat:@"%d", [rowDict[@"againstCount"] intValue]];
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status == RECOMMENDS && indexPath.section == 1) {
        return 152.0f;
    } else {
        return 143.0f;
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
    if (self.bookInfoDict && self.listRecommends && self.status == RECOMMENDS) {
        return [self.listRecommends count];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
}

// tell the delegate the table view is aobut to draw a cell for a pariticular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(XYRecBookCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0 && self.status == RECOMMENDS) {
        [cell setCollectionViewDataSourceDelegate:self index:(indexPath.section)];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 1 && self.status == RECOMMENDS) {
        XYCollectionCell * cell = (XYCollectionCell *) [collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            // pushViewController
            UIStoryboard *mainsb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            XYBookInfoController *bookInfoController = [mainsb instantiateViewControllerWithIdentifier:@"BookInfo"];
            bookInfoController.bookID = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:cell.title.tag]];
            [self.navigationController pushViewController:bookInfoController animated:YES];
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

- (void) loadBookDetailFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    NSString *path = [@"BookDetail/" stringByAppendingString:self.bookID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *tmp = (NSDictionary *)responseObject;
        if (tmp) {
            self.bookInfoDict = tmp[@"bookinfo"];
        }
        self.outputDict = tmp[@"details"];
        NSLog(@"loadBookDetailFromServer Success");
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadBookDetailFromServer Error:%@", error);
    }];
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
    NSString *path = [@"BookRelated/" stringByAppendingString:self.bookID];
    NSLog(@"path:%@",path);
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.listRecommends = (NSArray *)responseObject;
        NSLog(@"loadBookRecommendsFromServer Success");
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadBookRecommendsFromServer Error:%@", error);
    }];
}

@end
