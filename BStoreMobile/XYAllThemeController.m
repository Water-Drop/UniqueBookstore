//
//  XYAllThemeController.m
//  BStoreMobile
//
//  Created by Julie on 14-9-6.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYAllThemeController.h"
#import "XYUtil.h"

@interface XYAllThemeController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *listTheme;

@end

@implementation XYAllThemeController

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
    
    [self loadAllThemeFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadAllThemeFromServer
{
    NSURL *url = [NSURL URLWithString:BASEURLSTRING];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/html" , nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
    [manager GET:@"ClassList" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.listTheme = (NSArray *)responseObject;
        NSLog(@"loadAllThemeFromServer Success");
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadAllThemeFromServer Error:%@", error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.listTheme == nil) ? 0 : [self.listTheme count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"AllThemeCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *rowDict = [self.listTheme objectAtIndex:indexPath.row];
    NSInteger tagID = [rowDict[@"tagID"] integerValue];
    NSString *name = rowDict[@"name"];
    
    cell.tag = tagID;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.text = name;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowDict = [self.listTheme objectAtIndex:indexPath.row];
    NSInteger tagID = [rowDict[@"tagID"] integerValue];
    NSString *name = rowDict[@"name"];
    
    NSDictionary *valueDict = @{@"tagID":[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:tagID]], @"tagName":name};
    [self performSegueWithIdentifier:@"selectTheme" sender:valueDict];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectTheme"]) {
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
