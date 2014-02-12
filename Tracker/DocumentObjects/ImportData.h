//
//  ImportData.h
//  Tracker
//
//  Created by Justin Farlow on 11/8/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImportRow;

@interface ImportData : NSManagedObject

@property (nonatomic, retain) NSString * colDelim;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * indexI;
@property (nonatomic, retain) NSNumber * indexID;
@property (nonatomic, retain) NSNumber * indexT;
@property (nonatomic, retain) NSNumber * indexX;
@property (nonatomic, retain) NSNumber * indexY;
@property (nonatomic, retain) NSString * rawdata;
@property (nonatomic, retain) NSString * rowDelim;
@property (nonatomic, retain) NSSet *rows;
@end

@interface ImportData (CoreDataGeneratedAccessors)

- (void)addRowsObject:(ImportRow *)value;
- (void)removeRowsObject:(ImportRow *)value;
- (void)addRows:(NSSet *)values;
- (void)removeRows:(NSSet *)values;

@end
