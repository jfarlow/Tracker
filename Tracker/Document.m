//
//  Document.m
//  Tracker2
//
//  Created by Justin Farlow on 9/19/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import "Document.h"
#import "DocDelegate.h"
#import "AppDelegate.h"
#import "Experiment.h"
#import "Track.h"
#import "Spot.h"
#import "Preferences.h"
#import "Classification.h"

@implementation Document

////The Document's Delgate
@synthesize DocumentDelegate;
@synthesize PreferencesControllerOutlet;

///Controllers - be sure to link to the MOC during 'windowdidloadNib'
@synthesize ExperimentControllerOutlet;
@synthesize MSDControllerOutlet;
@synthesize TrackControllerOutlet;
@synthesize SpotControllerOutlet;
@synthesize ClassificationControllerOutlet;
@synthesize FrameControllerOutlet;


- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        
        //link the controllers to the managed object context
        
        
        
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    NSManagedObjectContext *context = [self managedObjectContext];
    [DocumentDelegate.ExperimentControllerOutlet setManagedObjectContext:context];
    [DocumentDelegate didFinishLaunching:nil];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}



- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName{
    return @"filename";
}

- (void)ImportDataFromURL:(NSURL *)inURL withRow:(NSString *)rowDelim withCol:(NSString *)colDelim withIDat:(NSNumber *)indexID withTat:(NSNumber *)indexT withXat:(NSNumber *)indexX withYat:(NSNumber *)indexY withIat:(NSNumber *)indexI{
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    Experiment *myExperiment = [NSEntityDescription insertNewObjectForEntityForName:@"Experiment" inManagedObjectContext:moc];
    myExperiment.name = [inURL lastPathComponent];
    
    //TrackSet *myTrackSet = [NSEntityDescription insertNewObjectForEntityForName:@"TrackSet" inManagedObjectContext:moc];
    //myTrackSet.experiment = myExperiment;
    
    NSString *fileContent = [[NSString alloc] initWithContentsOfURL:inURL encoding:NSUTF8StringEncoding error:nil];
    NSArray *allLines = [fileContent componentsSeparatedByString:rowDelim];

    NSInteger itemID = -1;
    
    Track *eachTrack = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:moc];
    
    if (allLines.count > 1) {
        for (NSInteger n=0;n<allLines.count; n++) {
            NSString *each = [allLines objectAtIndex:n];
            NSArray *allColumns = [each componentsSeparatedByString:colDelim];
            if (allColumns.count > 1) {
                NSInteger thisItemIndex = [[allColumns objectAtIndex:[indexID integerValue]] integerValue];
                if ((itemID == -1) || itemID != thisItemIndex ) {
                    if ([eachTrack.spots count] > 0) {
                        [myExperiment addTracksObject:eachTrack];
                        Track *newTrack = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:moc];
                        eachTrack = newTrack;
                    }
                    [eachTrack setId:[NSNumber numberWithInteger:thisItemIndex] ];
                    itemID = thisItemIndex;
                }
                Spot *eachSpot = [NSEntityDescription insertNewObjectForEntityForName:@"Spot" inManagedObjectContext:moc];
                
                eachSpot.t= [NSNumber numberWithFloat:[[allColumns objectAtIndex:[indexT integerValue]] floatValue]];
                eachSpot.x = [NSNumber numberWithFloat:[[allColumns objectAtIndex:[indexX integerValue]] floatValue]];
                eachSpot.y = [NSNumber numberWithFloat:[[allColumns objectAtIndex:[indexY integerValue]] floatValue]];
                eachSpot.i = [NSNumber numberWithFloat:[[allColumns objectAtIndex:[indexI integerValue]] floatValue]];
                eachSpot.track = eachTrack;
            }
        }
        
        [eachTrack setExperiment:myExperiment];
    }
}


@end







