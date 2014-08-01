//
//  XYLocationManager.m
//  BStoreMobile
//
//  Created by Jiguang on 7/21/14.
//  Copyright (c) 2014 SJTU. All rights reserved.
//

#import "XYLocationManager.h"

@implementation XYLocationManager

@synthesize showNavigation;

@synthesize current;

+ (XYLocationManager *)sharedManager
{
    static XYLocationManager *globalManager = nil;
    
    if (nil == globalManager) {
        globalManager  = [[[self class] alloc] init];
    }
    return globalManager;
}

- (id)init {
    self = [super init];
    
    showNavigation = NO;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
    
    // beacon points are indexed by their minor keys
    _beaconPoints = [NSDictionary dictionaryWithObjectsAndKeys:
                     [XYPoint point:@"B1" x:0 y:0], @"1",
                     [XYPoint point:@"B2" x:2.6 y:1.3], @"2",
                     [XYPoint point:@"B3" x:0 y:2.6], @"3", nil];
    
    current = [XYPoint point:@"Current" x:0 y:0];
    
    _beaconDistance = [[NSMutableDictionary alloc] init];
    
    _rangeCount = 0;
    
    return self;
}

- (void)initRegion
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.ister.myRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)showNavigationModal
{
    [self.delegate showNavigationModal];
}

#pragma CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.delegate performPayment];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    // clear records
    if (_rangeCount == 0) {
        [_beaconDistance removeAllObjects];
    }
    
    _rangeCount += 1;
    
    CLBeacon *beacon = [[CLBeacon alloc] init];
    
    for (beacon in beacons){
        // if the distance is measured, add to dictionary
        if (beacon.accuracy > 0) {
            NSString *key = [beacon.minor stringValue];
            NSMutableArray *array = [_beaconDistance objectForKey:key];
            
            if (array == nil) {
                array = [NSMutableArray array];
                // count
                [array addObject:[NSNumber numberWithInt:0]];
                // value sum
                [array addObject:[NSNumber numberWithDouble:0]];
                
                [_beaconDistance setObject:array forKey:key];
            }
            
            [array setObject:[NSNumber numberWithInt:[(NSNumber*)[array objectAtIndex:0] intValue]+1] atIndexedSubscript:0];
            [array setObject:[NSNumber numberWithDouble:[(NSNumber*)[array objectAtIndex:1] doubleValue]+beacon.accuracy] atIndexedSubscript:1];
        }
    }
    
    
    // do range 5 times, and calculate current location
    if (_rangeCount != 10) {
        return;
    }
    
    _rangeCount = 0;
    
    NSMutableDictionary *averageDistance = [NSMutableDictionary dictionary];
    
    NSArray *keys = [_beaconDistance allKeys];
    
    // calculate all saved beacons in last 10 range
    for (NSString *key in keys) {
        
        NSArray *array = [_beaconDistance objectForKey:key];
        
        double distance = [(NSNumber*)[array objectAtIndex:1] doubleValue] / [(NSNumber*)[array objectAtIndex:0] intValue];
        
        [averageDistance setObject:[NSNumber numberWithDouble:distance] forKey:key];
        NSLog(@"%@ %f", key, distance);
    }
    
    
    // average the points calculated by each pair of two beacons
    
    current.x = 0;
    current.y = 0;
    double count = 0;
    
    for (int i = 0; i < [keys count]; i++) {
        
        for (int j = i + 1; j < [keys count]; j++) {
            
            NSString *key1 = [keys objectAtIndex:i];
            NSString *key2 = [keys objectAtIndex:j];
            
            XYPoint* point = [self approximatePointWithDistances:averageDistance to:key1 to:key2];
            
            current.x += point.x;
            current.y += point.y;
            
            count += 1;
        }
    }
    
    current.x = current.x / count;
    current.y = current.y / count;
    
    NSLog(@"%f %f", current.x, current.y);
}

// approximate point location for given 2 beacons and distance to them
- (XYPoint*)approximatePointWithDistances:(NSMutableDictionary*)distances to:(NSString*)key1 to:(NSString*)key2
{
    XYPoint *np = [[XYPoint alloc] init];
    
    // two points
    XYPoint *p1 = [_beaconPoints objectForKey:key1];
    XYPoint *p2 = [_beaconPoints objectForKey:key2];
    
    // distance from p1 to p2
    double d = [p1 distanceTo:p2];
    
    // distacne from current to p1 and p2
    double d1 = [(NSNumber*)[distances objectForKey:key1] doubleValue];
    double d2 = [(NSNumber*)[distances objectForKey:key2] doubleValue];
    
    
    // sometimes the restrictions cannot be satisfied
    
    // distance to point1 and point2 too small
    if (d1 + d2 < d) {
        np.x = p1.x + (p2.x - p1.x) * (d1 + (d - d1 - d2) / 2) / d;
        np.y = p1.y + (p2.y - p1.y) * (d1 + (d - d1 - d2) / 2) / d;
        
    // distance to point1 too big
    } else if (d1 - d2 > d) {
        np.x = p1.x + (p2.x - p1.x) * (d + d2 + (d1 - d - d2) / 2) / d;
        np.y = p1.y + (p2.y - p1.y) * (d + d2 + (d1 - d - d2) / 2) / d;
        
    // distance to point2 too big
    } else if (d2 - d1 > d) {
        np.x = p2.x + (p1.x - p2.x) * (d + d1 + (d2 - d - d1) / 2) / d;
        np.y = p2.y + (p1.y - p2.y) * (d + d1 + (d2 - d - d1) / 2) / d;
        
    // at least one point satisfies the restriction
    } else {
        
        // y = ex + f
        double e = (p1.x - p2.x) / (p2.y - p1.y);
        double f = (pow(d1, 2) - pow(d2, 2) + pow(p2.y, 2) - pow(p1.y, 2) + pow(p2.x, 2) - pow(p1.x, 2)) / 2 / (p2.y - p1.y);
        
        // ax*x + bx + c = 0
        double a = 1 + pow(e, 2);
        double b = 2 * (e * (f - p1.y) - p1.x);
        double c = pow(p1.x, 2) + pow(f - p1.y, 2) - pow(d1, 2);
        
        double x1 = (- b + sqrt(pow(b, 2) - 4 * a * c) ) / 2 / a;
        double x2 = (- b - sqrt(pow(b, 2) - 4 * a * c) ) / 2 / a;
        
        
        // the two candidates
        
        XYPoint *np1 = [XYPoint point:@"CP1" x:x1 y:e * x1 + f];
        XYPoint *np2 = [XYPoint point:@"CP2" x:x2 y:e * x2 + f];
        
        double err1=0, err2=0;
        
        for (NSString *key in [distances allKeys]) {
            if ( ![key isEqualToString:key1] && ![key isEqualToString:key2] ) {
                err1 += [np1 distanceTo:[_beaconPoints objectForKey:key]];
                err2 += [np2 distanceTo:[_beaconPoints objectForKey:key]];
            }
        }
        
        if (err1 > err2) {
            np = np2;
        } else {
            np = np1;
        }
    }
    
    return np;
}

@end
