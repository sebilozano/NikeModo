//
//  Beacon.h
//  Nike
//
//  Created by Vincent Do on 11/2/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Beacon : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion * region;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSUUID * UUID;
@property (nonatomic) CLBeaconMajorValue major;
@property (nonatomic) CLBeaconMinorValue minor;

+ (Beacon *) instance;
- (void) initialize;
- (void) startMonitoringBeacon;

@end



