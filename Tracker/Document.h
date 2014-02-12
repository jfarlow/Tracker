//
//  Document.h
//  Tracker2
//
//  Created by Justin Farlow on 9/19/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocDelegate.h"

@interface Document : NSPersistentDocument
@property (strong) IBOutlet DocDelegate *DocumentDelegate;
@property (strong) IBOutlet NSArrayController *ExperimentControllerOutlet;
@property (strong) IBOutlet NSArrayController *PreferencesControllerOutlet;
@property (strong) IBOutlet NSArrayController *MSDControllerOutlet;
@property (strong) IBOutlet NSArrayController *TrackControllerOutlet;
@property (strong) IBOutlet NSArrayController *SpotControllerOutlet;
@property (strong) IBOutlet NSArrayController *ClassificationControllerOutlet;
@property (strong) IBOutlet NSArrayController *FrameControllerOutlet;





- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName;

- (void)ImportDataFromURL:(NSURL *)inURL withRow:(NSString *)rowDelim withCol:(NSString *)colDelim withIDat:(NSNumber *)indexID withTat:(NSNumber *)indexT withXat:(NSNumber *)indexX withYat:(NSNumber *)indexY withIat:(NSNumber *)indexI;

@end

