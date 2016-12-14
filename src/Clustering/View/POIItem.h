//
//  POIItem.h
//  Tucson
//
//  Created by Angela Mac on 14/12/2016.
//  Copyright © 2016 Kode. All rights reserved.
//


#import "GMUMarkerClustering.h"
#import <GoogleMaps/GoogleMaps.h>

// Point of Interest Item which implements the GMUClusterItem protocol.
@interface POIItem : NSObject<GMUClusterItem>

@property(nonatomic, readonly) CLLocationCoordinate2D position;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *titolo;

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position name:(NSString *)name titolo:(NSString *)titolo;

@end
