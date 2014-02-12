//
//  Experiment.h
//  Tracker2
//
//  Created by Justin Farlow on 10/16/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Frame, Track;

@interface Experiment : NSManagedObject

@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSNumber * doesCalcD;
@property (nonatomic, retain) NSNumber * doesCalcDC;
@property (nonatomic, retain) NSNumber * doesCalcMSD;
@property (nonatomic, retain) NSNumber * doesConstantlyCalculate;
@property (nonatomic, retain) NSString * imageFileFolder;
@property (nonatomic, retain) NSNumber * imagePixelsX;
@property (nonatomic, retain) NSNumber * imagePixelsY;
@property (nonatomic, retain) NSNumber * lengthScale;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * timeScale;
@property (nonatomic, retain) NSSet *imageStack;
@property (nonatomic, retain) NSSet *tracks;
@end

@interface Experiment (CoreDataGeneratedAccessors)

- (void)addImageStackObject:(Frame *)value;
- (void)removeImageStackObject:(Frame *)value;
- (void)addImageStack:(NSSet *)values;
- (void)removeImageStack:(NSSet *)values;

- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;

@end
