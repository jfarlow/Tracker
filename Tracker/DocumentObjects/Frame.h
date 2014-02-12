//
//  Frame.h
//  Tracker
//
//  Created by Justin Farlow on 11/8/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Experiment, Feature;

@interface Frame : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSNumber * t;
@property (nonatomic, retain) Experiment *experiment;
@property (nonatomic, retain) Feature *features;

@end
