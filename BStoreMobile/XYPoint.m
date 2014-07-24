//
//  XYPoint.m
//  BStoreMobile
//
//  Created by Jiguang on 7/22/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYPoint.h"

@implementation XYPoint

@synthesize x;
@synthesize y;
@synthesize valid;
@synthesize name;

- (id)init
{
    self = [super init];
    
    valid = true;
    
    return self;
}

+ (XYPoint*)point:(NSString*)name x:(double)x y:(double)y
{
    XYPoint *point = [[[self class] alloc] init];
    
    point.x = x;
    point.y = y;
    point.name = name;
    
    return point;
}

- (double)distanceTo:(XYPoint*)point
{
    return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2));
}

@end
