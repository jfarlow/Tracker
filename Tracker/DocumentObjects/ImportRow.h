//
//  ImportRow.h
//  Tracker
//
//  Created by Justin Farlow on 11/8/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImportData;

@interface ImportRow : NSManagedObject

@property (nonatomic, retain) NSNumber * i;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * t;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) ImportData *importData;

@end
