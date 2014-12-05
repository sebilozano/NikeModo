//
//  Beacon.m
//  Nike
//
//  Created by Vincent Do on 11/2/14.
//  Copyright (c) 2014 PennModo. All rights reserved.
//

#import "Beacon.h"
#import <Parse/Parse.h>

NSDate *lastBeaconTime;

@implementation Beacon

static Beacon *instance;

- (void) initialize {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.UUID = [[NSUUID alloc] initWithUUIDString:@"e2c56db5-dffb-48d2-b060-d0f5a71096e0"];
    self.major = (CLBeaconMajorValue) 01;
    self.minor = (CLBeaconMinorValue) 01;
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:self.UUID  major:(self.major) minor:(self.minor) identifier:@"Beacon"];
}

- (void)startMonitoringBeacon {
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startMonitoringForRegion:self.region];
    [self.locationManager stopRangingBeaconsInRegion:self.region];
    [self.locationManager startRangingBeaconsInRegion:self.region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSDate *date2 = [[NSDate alloc] init];
    NSString *regionID = region.identifier;
    NSString *regionText = @"region1";
    NSString *regionText2 = @"region2";
    
    if(state == CLRegionStateInside) {
        NSLog(@"locationManager didDetermineState INSIDE for %@", region.identifier);
        NSLog(@"stringcomp region1 %@", [region.identifier isEqualToString:@"region1"] ? @"YES" : @"NO");
        
        if([region.identifier isEqualToString:@"Beacon"]) {
            
            PFQuery *innerQuery = [PFUser query];
            
            PFUser * currentUser = [PFUser currentUser];
            
            [innerQuery whereKey:@"email" equalTo:currentUser[@"email"]];
            
            PFQuery *query = [PFInstallation query];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            [push setMessage:@"Welcome to Nike!"];
            [push sendPushInBackground];
            
        }
        //}
        
    
    }
    else if(state == CLRegionStateOutside) {
        NSLog(@"Whatever");
//        beaconFound = false;
        
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        NSLog(@"locationManager didDetermineState OUTSIDE for %@", region.identifier);
    }
    else {
        NSLog(@"locationManager didDetermineState OTHER for %@", region.identifier);
    }
}

-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
        //UILocalNotification *notification = [[UILocalNotification alloc] init];
        //notification.alertBody = @"Found Beacon";
        //notification.soundName = @"Default";
        //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        NSLog(@"%@",[beacons componentsJoinedByString:@":"]);
        
        NSDate *date2 = [[NSDate alloc] init];
        
        CLBeacon *beacon;
        for(beacon in beacons)
        {
            NSLog(@"Saw beacon %@", beacon);
            
            if((lastBeaconTime == nil || fabs([date2 timeIntervalSinceDate:lastBeaconTime]) > (60 * 1)) && [beacon.major  isEqual: @2])
            {
                NSLog(@"Found beacon with major 2");
                
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif == nil)
                    return;
                
                localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Fill up at Empire!", nil)];
                
                localNotif.alertAction = NSLocalizedString(@"View Details", nil);
                
                localNotif.soundName = UILocalNotificationDefaultSoundName;
                localNotif.applicationIconBadgeNumber = 0;
                
                NSDictionary *beaconInfo = @{@"minor" : beacon.minor, @"major" : beacon.major, @"UUID" : beacon.proximityUUID.UUIDString,  };
                
                localNotif.userInfo = beaconInfo;
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                
                
                lastBeaconTime = [[NSDate alloc] init];
            }
        }
    }
}

+ (Beacon *)instance {
    if (!instance) {
        instance = [[Beacon alloc] init];
    }
    return instance;
}

@end
