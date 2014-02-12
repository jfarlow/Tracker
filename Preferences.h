//
//  Preferences.h
//  Tracker
//
//  Created by Justin Farlow on 11/8/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Preferences : NSManagedObject

@property (nonatomic, retain) NSString * alertMessage;
@property (nonatomic, retain) NSNumber * blackLevel;
@property (nonatomic, retain) NSNumber * isAutoAdjImage;
@property (nonatomic, retain) NSNumber * isShowingImage;
@property (nonatomic, retain) NSNumber * isShowingPoint;
@property (nonatomic, retain) NSNumber * isShowingTrack;
@property (nonatomic, retain) NSNumber * isTrackEditable;
@property (nonatomic, retain) NSNumber * spotSize;
@property (nonatomic, retain) id trackColor;
@property (nonatomic, retain) NSNumber * usesNaturalUnits;
@property (nonatomic, retain) NSNumber * whiteLevel;
@property (nonatomic, retain) NSNumber * zoomLevel;

@end
