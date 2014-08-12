//
//  XYPubMsgController.m
//  BStoreMobile
//
//  Created by Julie on 14-7-21.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYPubMsgController.h"
#import "Names.h"

#define NAV_BAR_HEIGHT 64

enum pubStatus {
    PUBLIC, PRIVATE
};

@interface XYPubMsgController ()
//@property (weak, nonatomic) IBOutlet UITextView *textView;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property enum pubStatus status;
- (IBAction)pubMsg:(id)sender;
@property NSMutableArray *bookIDs;
//@property BOOL pubToPublic;

- (void)resizeViews;

@end

@implementation XYPubMsgController {
	TITokenFieldView * _tokenFieldView;
	UITextView * _messageView;
	
	CGFloat _keyboardHeight;
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
    
//    self.status = PRIVATE;
//    self.pubToPublic = NO;
    
//    self.textView.delegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];

    // not used in ios 7.0(http://blog.sina.com.cn/s/blog_6291e42d0101f6b0.html)
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
//        self.edgesForExtendedLayout = UIRectEdgeNone;
	[self.view setBackgroundColor:[UIColor whiteColor]];
    CGRect rect = self.view.bounds;
    rect.origin.y = NAV_BAR_HEIGHT;
    rect.size.height -= NAV_BAR_HEIGHT;
	_tokenFieldView = [[TITokenFieldView alloc] initWithFrame:rect];
	[_tokenFieldView setSourceArray:[Names listOfNames]];
	[self.view addSubview:_tokenFieldView];
	
	[_tokenFieldView.tokenField setDelegate:self];
	[_tokenFieldView setShouldSearchInBackground:NO];
	[_tokenFieldView setShouldSortResults:NO];
	[_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:TITokenFieldControlEventFrameDidChange];
	[_tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@""]]; // Default is a comma
    [_tokenFieldView.tokenField setPromptText:@"关于:"];
	[_tokenFieldView.tokenField setPlaceholder:@"你想要评论的书籍..."];
	
	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
	[_tokenFieldView.tokenField setRightView:addButton];
	[_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
	[_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
	
	_messageView = [[UITextView alloc] initWithFrame:_tokenFieldView.contentView.bounds];
	[_messageView setScrollEnabled:NO];
	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
	[_messageView setDelegate:self];
	[_messageView setFont:[UIFont systemFontOfSize:15]];
	[_tokenFieldView.contentView addSubview:_messageView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// You can call this on either the view on the field.
	// They both do the same thing.
	[_tokenFieldView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSLog(@"SELECT ITEM:%@", self.selectItem);
    BOOL isContained = NO;
    //    for (TIToken *token in _tokenFieldView.tokenField.tokens) {
    //        NSLog(@"token title:%@", token.title);
    //    }
    if (self.selectItem) {
        for (TIToken *token in _tokenFieldView.tokenField.tokens) {
            if ([token.title isEqualToString:self.selectItem]) {
                isContained = YES;
                break;
            }
        }
        if (!isContained) {
            NSLog(@"comes here");
            TIToken * token = [_tokenFieldView.tokenField addTokenWithTitle:self.selectItem];
            //            [token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
            // If the size of the token might change, it's a good idea to layout again.
            [_tokenFieldView.tokenField layoutTokensAnimated:YES];
            NSUInteger tokenCount = _tokenFieldView.tokenField.tokens.count;
            NSLog(@"tokens count from selection:%@", [NSNumber numberWithInteger:tokenCount]);
            [token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 3) == 1 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
            self.selectItem = nil;
        }
    }
    [_tokenFieldView becomeFirstResponder];
    //    for (TIToken *token in _tokenFieldView.tokenField.tokens) {
    //        NSLog(@"token title:%@", token.title);
    //    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self resizeViews];}]; // Make it pweeetty.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resizeViews];
}

- (void)showContactsPicker:(id)sender {
	
	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.
	
    //	NSArray * names = [Names listOfNames];
    //
    //	TIToken * token = [_tokenFieldView.tokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
    //	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
    //	// If the size of the token might change, it's a good idea to layout again.
    //	[_tokenFieldView.tokenField layoutTokensAnimated:YES];
    //
    //	NSUInteger tokenCount = _tokenFieldView.tokenField.tokens.count;
    //	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
    [self performSegueWithIdentifier:@"selectPaid" sender:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
    int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
	[_tokenFieldView setFrame:((CGRect){_tokenFieldView.frame.origin, {self.view.bounds.size.width, self.view.bounds.size.height - NAV_BAR_HEIGHT + tabBarOffset - _keyboardHeight}})];
	[_messageView setFrame:_tokenFieldView.contentView.bounds];
}

- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
	
	if ([token.title isEqualToString:@"Tom Irving"]){
		return NO;
	}
	
	return YES;
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField {
	[self textViewDidChange:_messageView];
}

- (void)textViewDidChange:(UITextView *)textView {
	
	CGFloat oldHeight = _tokenFieldView.frame.size.height - _tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = _tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < oldHeight){
		newTextFrame.size.height = oldHeight;
		newFrame.size.height = oldHeight;
	}
    
	[_tokenFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[_tokenFieldView updateContentSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 2;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *cellID = @"PubMsgCellIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//    }
//    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
//    UIColor *color = [UIColor lightGrayColor];
//    if (self.pubToPublic == YES) {
//        color = [UIColor blackColor];
//    } else {
//        self.status = PRIVATE;
//    }
//    if (indexPath.row == 0) {
//        cell.textLabel.text = @"仅好友圈可见";
//        if (self.status == PUBLIC) {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        } else if (self.status == PRIVATE) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
//    } if (indexPath.row == 1) {
//        cell.textLabel.text = @"公共可见（同步到书籍评论）";
//        if (self.status == PUBLIC) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        } else if (self.status == PRIVATE) {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//    }
//    cell.textLabel.textColor = color;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.pubToPublic) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        int others = (indexPath.row == 0 ? 1 : 0);
//        self.status = (indexPath.row == 0 ? PRIVATE : PUBLIC);
//        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:others inSection:0];
//        UITableViewCell *otherCell = [self.tableView cellForRowAtIndexPath:otherIndexPath];
//        otherCell.accessoryType = UITableViewCellAccessoryNone;
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        NSLog(@"pub status:%u", self.status);
//    }
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return @"选择消息的发布方式";
//    } else {
//        return nil;
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - unused

- (IBAction)pubMsg:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发布成功" message:@"你已成功发送消息" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

//- (void)textViewDidChange:(UITextView *)textView
//{
//    NSRange foundObj=[textView.text rangeOfString:@"#" options:NSCaseInsensitiveSearch];
//    if(foundObj.length>0) {
//        self.pubToPublic = YES;
//    } else {
//        self.pubToPublic = NO;
//    }
//    if ([textView.text hasSuffix:@"#"]) {
//        NSLog(@"Ended with #");
//    }
//    [self.tableView reloadData];
//}

@end
