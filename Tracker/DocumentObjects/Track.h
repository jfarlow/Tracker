//
//  Track.h
//  Tracker2
//
//  Created by Justin Farlow on 11/5/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Experiment, MSD, Spot;

@interface Track : NSManagedObject

@property (nonatomic, retain) NSNumber * alpha;
@property (nonatomic, retain) NSString * classification;
@property (nonatomic, retain) NSNumber * dcIntercept;
@property (nonatomic, retain) NSNumber * dcRangeMax;
@property (nonatomic, retain) NSNumber * dcRangeMin;
@property (nonatomic, retain) NSNumber * dcRSquared;
@property (nonatomic, retain) NSNumber * diffusionCoefficient;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * maxXDistance;
@property (nonatomic, retain) NSNumber * maxYDistance;
@property (nonatomic, retain) Experiment *experiment;
@property (nonatomic, retain) NSSet *msds;
@property (nonatomic, retain) NSSet *spots;
@property (nonatomic, retain) NSNumber * maxDistance;
@property (nonatomic, retain) NSNumber * maxIntensity;
@property (nonatomic, retain) NSNumber * minIntensity;
@property (nonatomic, retain) NSNumber * avgIntensity;
@end

@interface Track (CoreDataGeneratedAccessors)

- (void)addMsdsObject:(MSD *)value;
- (void)removeMsdsObject:(MSD *)value;
- (void)addMsds:(NSSet *)values;
- (void)removeMsds:(NSSet *)values;

- (void)addSpotsObject:(Spot *)value;
- (void)removeSpotsObject:(Spot *)value;
- (void)addSpots:(NSSet *)values;
- (void)removeSpots:(NSSet *)values;

@end
