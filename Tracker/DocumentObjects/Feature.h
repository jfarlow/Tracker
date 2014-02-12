//
//  Feature.h
//  Tracker
//
//  Created by Justin Farlow on 11/8/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Frame;

@interface Feature : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * integratedIntensity;
@property (nonatomic, retain) NSNumber * identification;
@property (nonatomic, retain) Frame *frame;

@end
