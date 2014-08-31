//
//  XYUtil.m
//  BStoreMobile
//
//  Created by Julie on 14-7-24.
//  Copyright (c) 2014年 SJTU. All rights reserved.
//

#import "XYUtil.h"

@implementation XYUtil

+ (void)parseJsonTest {
    NSError *error;
    
    // 加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.weather.com.cn/data/101180601.html"]];
    // 将请求的URL数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    // IOS5自带的解析类NSJSONSerialization从response中解析出数据放到字典中
    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    NSDictionary *weatherInfo = [weatherDic objectForKey:@"weatherinfo"];
    NSString *result = [NSString stringWithFormat:@"今天是 %@  %@  %@  的天气状况是：%@  %@ ",[weatherInfo objectForKey:@"date_y"],[weatherInfo objectForKey:@"week"],[weatherInfo objectForKey:@"city"], [weatherInfo objectForKey:@"weather1"], [weatherInfo objectForKey:@"temp1"]];
    NSLog(@"%@", result);
    NSLog(@"weatherInfo字典里面的内容为--》%@", weatherDic );
    
    NSLog(@"--------");
    NSString *str = @"{\"name\":\"kaixuan_166\"}";
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    // 没问题，使用NSJSONReadingMutableContainers，则返回的对象是可变的，NSMutableDictionary
    [dict setObject:@"male" forKey:@"sex"];
    
    NSLog(@"dict:::: %@", dict);
}

+ (NSDictionary *)parseRecBookInfo {
    NSString *recBookInfo = @"{\"toprated\":[{\"title\":\"A1-南非\", \"author\":\"南非，南非\", \"coverimg\":\"SouthAfrica\"}, {\"title\":\"A2-墨西哥\", \"author\":\"墨西哥，墨西哥\", \"coverimg\":\"Mexico\"}], \"recommend\":[{\"title\":\"B1-西班牙\", \"author\":\"西班牙，西班牙\", \"coverimg\":\"Spain\"}, {\"title\":\"B2-澳大利亚\", \"author\":\"澳大利亚\", \"coverimg\":\"Australia\"}, {\"title\":\"B3-荷兰\", \"author\":\"罗本，范佩西\", \"coverimg\":\"Holland\"}, {\"title\":\"B4-智利\", \"author\":\"智利，智利，智利，智利\", \"coverimg\":\"Chile\"}, {\"title\":\"B5-英格兰\", \"author\":\"伊丽莎白，伊丽莎白\", \"coverimg\":\"England\"}]}";
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[recBookInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    return dict;
}

+ (void)showButtonBorder: (UIButton *)button
{
    // used in iOS 7
    if ([button isKindOfClass:[UIButton class]]) {
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:5.0]; //设置矩圆角半径
        [button.layer setBorderWidth:1.0];   //边框宽度
        CGColorRef colorref = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
        [button.layer setBorderColor:colorref];//边框颜色
    }
}

+ (NSString *)printMoneyAtCent:(int) moneyAtCent
{
    int money0 = moneyAtCent / 100;
    int money1 = moneyAtCent % 100;
    NSString *money = [NSString stringWithFormat:@"￥%d.%d", money0, money1];
    return money;
}

+ (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

+ (NSString *)getUserID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userList = [defaults objectForKey:@"userList"];
    if (userList) {
        NSString *userID = [userList objectForKey:@"userID"];
        if (userID && [XYUtil isPureInt:userID]) {
            return userID;
        }
    }
    return nil;
}

//判断是否为整形：

+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：

+ (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
@end
