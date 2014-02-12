//
//  Track.m
//  Tracker2
//
//  Created by Justin Farlow on 11/5/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import "Track.h"
#import "Experiment.h"
#import "MSD.h"
#import "Spot.h"


@implementation Track

@dynamic alpha;
@dynamic classification;
@dynamic dcIntercept;
@dynamic dcRangeMax;
@dynamic dcRangeMin;
@dynamic dcRSquared;
@dynamic diffusionCoefficient;
@dynamic id;
@dynamic maxXDistance;
@dynamic maxYDistance;
@dynamic experiment;
@dynamic msds;
@dynamic spots;
@dynamic maxIntensity;
@dynamic maxDistance;
@dynamic minIntensity;
@dynamic avgIntensity;

- (NSNumber *)maxDistance {
    return [self valueForKeyPath:@"spots.@max.distanceTo"];
}

- (NSNumber *)minIntensity{
    return [self valueForKeyPath:@"spots.@min.i"];
}

- (NSNumber *)avgIntensity{
    return [self valueForKeyPath:@"spots.@avg.i"];
}

- (NSNumber *)maxIntensity{
    return [self valueForKeyPath:@"spots.@max.i"];
}


@end
