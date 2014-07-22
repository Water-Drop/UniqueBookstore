//
//  XYPoint.h
//  BStoreMobile
//
//  Created by Jiguang on 7/22/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYPoint : NSObject

@property double x;
@property double y;
@property bool valid;
@property (copy) NSString *name;

+ (XYPoint*)point:(NSString*)name x:(double)x y:(double)y;

- (double)distanceTo:(XYPoint*)point;

@end
