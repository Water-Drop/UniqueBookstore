//
//  XYLocationManager.h
//  BStoreMobile
//
//  Created by Jiguang on 7/21/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface XYLocationManager : NSObject <CLLocationManagerDelegate>

+ (XYLocationManager *)sharedInstance;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *beacons;

@end
