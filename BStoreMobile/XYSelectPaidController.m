//
//  TTSelectPaidController.m
//  TokenTextViewSample
//
//  Created by Julie on 14-8-11.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYSelectPaidController.h"
#import "Names.h"
#import "XYPubMsgController.h"

@interface XYSelectPaidController ()

@property NSArray *names;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)cancelAction:(id)sender;

@end

@implementation XYSelectPaidController

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
    self.names = [Names listOfNames];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.names count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"SelectedPaidCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [self.names objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nav = (UINavigationController *)self.presentingViewController;
    NSInteger idx = [nav.viewControllers count] - 1;
    XYPubMsgController *pm = nav.viewControllers[idx];
    NSLog(@"parentViewController class:%@", NSStringFromClass([pm class]));
    pm.selectItem = [self.names objectAtIndex:indexPath.row];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
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
@end
