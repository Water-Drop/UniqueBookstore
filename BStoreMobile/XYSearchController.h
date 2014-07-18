//
//  XYSearchController.h
//  BStoreMobile
//
//  Created by Jiguang on 7/18/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYSearchController : UIViewController <UISearchBarDelegate>

- (IBAction)valueChanged:(id)sender;
@property (nonatomic, strong) NSArray *listCart;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
