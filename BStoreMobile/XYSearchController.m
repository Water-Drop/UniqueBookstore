//
//  XYSearchController.m
//  BStoreMobile
//
//  Created by Jiguang on 7/18/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYSearchController.h"
#import "XYSaleItemCell.h"

@implementation XYSearchController

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
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma customize table view

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"shouldBeginEditing");
    self.searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    UIView *topView = self.searchBar.subviews[0];
    for(UIView* subview in topView.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            UIButton *btn = (UIButton*)subview;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"cancleButtonClicked");
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchButtonClicked");
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
    [self doSearch:self.searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"SearchBarTextChanged");
    if (0 == self.searchBar.text.length) {
        NSLog(@"Clear Table View");
        //clear table view
        self.listItem = [NSArray array];
        [self.tableView reloadData];
    }
}


#pragma UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.listItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    
    // 从xib中创建，不在sb中的tableview里添加prototype(否则关联的outlet是nil，没有初始化，main interface是sb)
    static NSString *CellIdentifier = @"CellIdentifier";
    XYSaleItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // XYSaleItemCell.xib as NibName
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XYSaleItemCell" owner:nil options:nil];
        //第一个对象就是CellIdentifier了（xib所列子控件中的最高父控件，CellIdentifier）
        cell = [nib objectAtIndex:0];
    }
    if (cell == nil) {
        NSLog(@"NILLLLL");
    }
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    NSDictionary *rowDict = [self.listItem objectAtIndex:row];
    cell.title.text = [rowDict objectForKey:@"name"];
    
    NSString *imagePath = [rowDict objectForKey:@"image"];
    imagePath = [imagePath stringByAppendingString:@".png"];
    cell.coverImage.image = [UIImage imageNamed:imagePath];
    
    NSString *detail = [rowDict objectForKey:@"detail"];
    cell.detail.text = detail;
    
    NSString *price = @"￥";
    price = [price stringByAppendingString:[rowDict objectForKey:@"price"]];
    [cell.buyButton setTitle:price forState: UIControlStateNormal];
    
    //Add action method
    [cell.navButton addTarget:self action:@selector(navBookInfo:) forControlEvents:UIControlEventTouchUpInside];
    [cell.navButton setTag:indexPath.row];
    
    return cell;
}

#pragma UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103.0f;
}

#pragma control display content

- (void)doSearch:(NSString*)searchText {
    
    //TODO: sample
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"cart" ofType:@"plist"];
    self.listItem = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    [self.tableView reloadData];
    
    NSLog(@"XYSearchController loadPlistFile of size %lu",(unsigned long)[self.listItem count]);
}

#pragma navigation

- (void)navBookInfo:(id)sender
{
    UIButton *btn = (UIButton*) sender;
    //TODO: use btn.tag to access json
    NSLog(@"%lu", (unsigned long)btn.tag);
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"cart" ofType:@"plist"];
    self.listItem = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSDictionary *rowDict = [self.listItem objectAtIndex:btn.tag];
    
    self.valueDict = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"titleStr",[rowDict objectForKey:@"name"],
                      @"detailStr",[rowDict objectForKey:@"detail"],
                      nil];
    [self performSegueWithIdentifier:@"SearchBookDetail" sender:self];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchBookDetail"]) {
        UIViewController *dest = segue.destinationViewController;
        if (self.valueDict) {
            for (NSString *key in self.valueDict) {
                NSLog(@"%@, %@", key, self.valueDict[key]);
                [dest setValue:key forKey:self.valueDict[key]];
            }
        }
    }

}


@end
