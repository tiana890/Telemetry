//
//  POIItem.h
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Clustering/GMUClusterItem.h"

@interface POIItem : NSObject<GMUClusterItem>

@property (nonatomic) NSString* name;
@property (nonatomic) CLLocationCoordinate2D position;
@property (nonatomic) NSString *prevLat;
@property (nonatomic) NSString *prevLon;
@property (nonatomic) NSNumber *azimut;
@property (nonatomic) BOOL hasAnimated;
@end
