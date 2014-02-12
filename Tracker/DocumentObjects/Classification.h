//
//  Classification.h
//  Tracker2
//
//  Created by Justin Farlow on 10/16/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Classification : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * icon;

@end
