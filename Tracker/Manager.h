//
//  Manager.h
//  Tracker2
//
//  Created by Justin Farlow on 9/19/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Manager : NSObject

-(void)TestParse;

-(void)ParseImport;
@end


@interface SortPopUp : NSPopUpButton
@property (nonatomic, retain) NSString * sortKey;
-(void)setSortKey:(NSString *)input;
@end