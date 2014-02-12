//
//  MSD.h
//  Tracker2
//
//  Created by Justin Farlow on 9/25/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Track;

@interface MSD : NSManagedObject

@property (nonatomic, retain) NSNumber * deltaT;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) Track *track;

@end
