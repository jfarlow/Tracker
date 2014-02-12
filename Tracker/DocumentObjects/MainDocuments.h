//
//  MainDocuments.h
//  Tracker
//
//  Created by Justin Farlow on 11/8/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MainDocuments : NSManagedObject

@property (nonatomic, retain) NSNumber * isOpen;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;

@end
