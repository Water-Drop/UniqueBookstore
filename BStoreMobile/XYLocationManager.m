//
//  XYLocationManager.m
//  BStoreMobile
//
//  Created by Jiguang on 7/21/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYLocationManager.h"

@implementation XYLocationManager

+ (XYLocationManager *)sharedInstance
{
    static XYLocationManager *myInstance = nil;
    
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
    }
    return myInstance;
}

- (id)init {
    self = [super init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
    return self;
}

- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.ister.myRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

#pragma CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    _beacons = beacons;
    
    CLBeacon *beacon = [[CLBeacon alloc] init];
    
    for (beacon in beacons) {
        NSString *distance;
        if (beacon.proximity == CLProximityUnknown) {
            distance = @"Unknown Proximity";
        } else if (beacon.proximity == CLProximityImmediate) {
            distance = @"Immediate";
        } else if (beacon.proximity == CLProximityNear) {
            distance = @"Near";
        } else if (beacon.proximity == CLProximityFar) {
            distance = @"Far";
        }
        NSLog(@"%@, %@, %@, %f, %li, %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor, beacon.accuracy, (long)beacon.rssi, distance);
    }
}

@end
