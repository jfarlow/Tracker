//
//  Spot.h
//  Tracker2
//
//  Created by Justin Farlow on 9/25/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Track;

@interface Spot : NSManagedObject

@property (nonatomic, retain) NSNumber * distanceTo;
@property (nonatomic, retain) NSNumber * i;
@property (nonatomic, retain) NSNumber * t;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) Track *track;

@end
