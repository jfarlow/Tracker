//
//  DocDelegate.m
//  Tracker2
//
//  Created by Justin Farlow on 9/20/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DocDelegate.h"
#import "Document.h"
#import "Track.h"
#import "Spot.h"
#import "Frame.h"
#import "MSD.h"
#import "Preferences.h"
#import "Experiment.h"
#import "MathArray.h"
#import "ImageCanvas.h"
#import "Classification.h"
#import "AppDelegate.h"
#import "Manager.h"

@implementation DocDelegate
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedDocObjectModel = _managedDocObjectModel;
@synthesize managedDocObjectContext = _managedDocObjectContext;
@synthesize trackFilterArray;

/////controller syntheses
@synthesize ExperimentControllerOutlet;
@synthesize TrackControllerOutlet;
@synthesize SpotControllerOutlet;
@synthesize MSDControllerOutlet;
@synthesize ClassificationControllerOutlet;
@synthesize PreferencesControllerOutlet;
@synthesize FrameControllerOutlet;
@synthesize EveryTrackControllerOutlet;

@synthesize TrackCanvasOutlet;
@synthesize AlertMessageLabelOutlet;
@synthesize InfoWindowOutlet;
@synthesize UnitsOfChoiceOutlet;
@synthesize TrackKindTabViewOutlet;

////Tab outlets
@synthesize TabbedViewOutlet;
@synthesize DistanceLinegraphOutlet;
@synthesize IntensityLinegraphOutlet;
@synthesize MSDLinegraphOutlet;
@synthesize ProgressBarOutlet;
@synthesize MaxTauOutlet;

@synthesize TogetherMSDGraph;

///mainpage
@synthesize ScaleWindowOutlet;
@synthesize MainViewOutlet;

////report Objects
@synthesize reportAlphaOutlet;
@synthesize reportDiffusionOutlet;
@synthesize reportNumberOutlet;


///////images
@synthesize UseContrastSliderOutlet;
@synthesize ContrastSliderOutlet;
@synthesize ExposureSliderOutlet;
@synthesize ImageOutlet;
@synthesize BlackPointSliderOutlet;
@synthesize WhitePointSliderOutlet;



//TableOutlets
@synthesize TrackTableOutlet;
@synthesize AnalysisTableOutlet;
@synthesize SpotTableOutlet;




/////testingfunctinos
@synthesize ThreshholdSliderOutlet;
@synthesize BoxSizeOutlet;
@synthesize ToleranceOutlet;

- (void)didFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

    trackFilterArray = [[NSArray alloc] init];
    
    NSManagedObjectContext *context = [ExperimentControllerOutlet managedObjectContext];
    [FrameControllerOutlet setManagedObjectContext:context];
    [MSDControllerOutlet setManagedObjectContext:context];
    [SpotControllerOutlet setManagedObjectContext:context];
    [TrackControllerOutlet setManagedObjectContext:context];
    [EveryTrackControllerOutlet setManagedObjectContext:context];
    [ClassificationControllerOutlet setManagedObjectContext:context];
    
    
    NSSortDescriptor* sortByID = [[NSSortDescriptor alloc] initWithKey: @"id" ascending: YES];
    [TrackControllerOutlet setSortDescriptors:[NSArray arrayWithObject:sortByID]];
    NSSortDescriptor* sortByT = [[NSSortDescriptor alloc] initWithKey: @"t" ascending: YES];
    [SpotControllerOutlet setSortDescriptors:[NSArray arrayWithObject:sortByT]];
    [FrameControllerOutlet setSortDescriptors:[NSArray arrayWithObject:sortByT]];
    NSSortDescriptor* sortByDeltaT = [[NSSortDescriptor alloc] initWithKey: @"deltaT" ascending: YES];
    [MSDControllerOutlet setSortDescriptors:[NSArray arrayWithObject:sortByDeltaT]];

    if ([[ClassificationControllerOutlet arrangedObjects] count] == 0) {
        //initialize Classifications
        Classification *defaultClass1 = [ClassificationControllerOutlet newObject];
        defaultClass1.name = @"Useful";
        defaultClass1.icon = @"NSStatusAvailable";
        Classification *defaultClass2 = [ClassificationControllerOutlet newObject];
        defaultClass2.name = @"Discard";
        defaultClass2.icon = @"NSStatusUnavailable";
        Classification *defaultClass3 = [ClassificationControllerOutlet newObject];
        defaultClass3.name = @"Other";
        defaultClass3.icon = @"NSStatusPartiallyAvailable";
        [ClassificationControllerOutlet addObjects:[NSArray arrayWithObjects:defaultClass1,defaultClass2,defaultClass3, nil]];
    }
    [self UpdateClassificationMenu];
    
    ///initialize Prefs
    if ([[PreferencesControllerOutlet arrangedObjects] count] ==0) {
        
        Preferences *myPrefs = [NSEntityDescription insertNewObjectForEntityForName:@"Preferences" inManagedObjectContext:[self managedDocObjectContext]];
        myPrefs.trackColor = [NSColor blueColor];
        [PreferencesControllerOutlet addObject:myPrefs];
    }
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "tracker" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"gartner.tracker"];
}

- (NSManagedObjectModel *)managedDocObjectModel
{
    if (_managedDocObjectModel) {
        return _managedDocObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Document" withExtension:@"momd"];
    _managedDocObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedDocObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedDocObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Document.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedDocObjectContext
{
    if (_managedDocObjectContext) {
        return _managedDocObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedDocObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedDocObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedDocObjectContext;
}


- (IBAction)ChooseUnits:(id)sender {
    Experiment *myExpt = [[ExperimentControllerOutlet arrangedObjects] objectAtIndex:0];
    if ([myExpt.lengthScale floatValue] <= 0 || [myExpt.timeScale floatValue] <= 0) {
        [self UnitAlert];
    }
    
    [TrackTableOutlet reloadData];
    [AnalysisTableOutlet reloadData];
    [SpotTableOutlet reloadData];
    
}

- (IBAction)InfoWindow:(id)sender {
    if ([InfoWindowOutlet.window isVisible]) {
        [InfoWindowOutlet.window close];
    }else{
        [InfoWindowOutlet.window makeKeyAndOrderFront:self];
    }
}

- (IBAction)CalculateCurrentTracks:(id)sender {
    NSArray *trackArray = [TrackControllerOutlet selectedObjects];
    [self RunCalculations:trackArray];
    [self UpdateGraphs];
}

- (IBAction)CalculateAllTracks:(id)sender {
    NSArray *trackArray = [TrackControllerOutlet arrangedObjects];
    [self RunCalculations:trackArray];
    [self UpdateGraphs];
}


-(void)RunCalculations:(NSArray *)trackArray{
    [ProgressBarOutlet setHidden:NO];
    [ProgressBarOutlet setAlphaValue:1.f];
    [ProgressBarOutlet setMaxValue:trackArray.count];
    [ProgressBarOutlet setDoubleValue:0];

    for (Track *myTrack in trackArray) {
        [ProgressBarOutlet incrementBy:1];
        
        Experiment *myExperiment = myTrack.experiment;
        NSSortDescriptor* sortByT = [[NSSortDescriptor alloc] initWithKey: @"t" ascending: YES];
        NSSortDescriptor* sortByDeltaT = [[NSSortDescriptor alloc] initWithKey: @"deltaT" ascending: YES];
        
        NSArray *mySpots = [[myTrack.spots allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByT]];
        NSArray *spotXs = [mySpots valueForKey:@"x"];
        NSArray *spotYs = [mySpots valueForKey:@"y"];
        float timescale = [myExperiment.timeScale floatValue];
        float lengthscale = [myExperiment.lengthScale floatValue];
        if (lengthscale==0) {
            lengthscale = 1; [self UnitAlert];
        }
        if (timescale==1) {
            lengthscale = 1; [self UnitAlert];
        }
        
        ///calculate distances
        if (myExperiment.doesCalcD) {
            Spot *initialSpot = [mySpots objectAtIndex:0];
            for (int i=0; i<mySpots.count; i++) {
                Spot *eachSpot = [mySpots objectAtIndex:i];
                float x0 = [initialSpot.x floatValue];
                float y0 = [initialSpot.y floatValue];
                float x1 = [eachSpot.x floatValue];
                float y1 = [eachSpot.y floatValue];
                float d =sqrtf(powf(( x1- x0), 2.0) + powf((y1 - y0), 2.0));
                eachSpot.distanceTo = [NSNumber numberWithFloat:d];
            }
        }
        
        ////Calculate MSDs
        if (myExperiment.doesCalcMSD) {
            myTrack.msds = nil;
            NSInteger absMaxTau = floorf(spotXs.count / 2);
            NSInteger maxTau = 0;
            
            NSInteger tauIndex =  [MaxTauOutlet indexOfSelectedItem];
            if (tauIndex==0) {
                maxTau = absMaxTau;
            }else if (tauIndex==1){
                maxTau = floorf(spotXs.count / 3);
            }else if (tauIndex==2){
                maxTau = 20;
            }else if (tauIndex==3){
                maxTau = 50;
            }
            if (maxTau > absMaxTau) {
                maxTau = absMaxTau;
            }
            
            for (int i=0; i < maxTau; i++) {
                MSD *thisMSD = [NSEntityDescription insertNewObjectForEntityForName:@"MSD" inManagedObjectContext:[TrackControllerOutlet managedObjectContext]];
                float dT = (i + 1) * [myExperiment.timeScale floatValue];
                float msd = [self CalculateMSDfromXs:spotXs andYs:spotYs withTau:(i+1)];
                thisMSD.deltaT =[NSNumber numberWithFloat:(dT)];
                thisMSD.distance = [NSNumber numberWithFloat:(msd * lengthscale * lengthscale)];
                thisMSD.track = myTrack;
            }
        }
        
        //////calculate Diffusion Coefficients
        if (myExperiment.doesCalcDC) {
            NSArray *MSDs = [[myTrack.msds allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByDeltaT]];
            NSArray *distanceArray = [MSDs valueForKey:@"distance"];
            NSArray *tauArray = [MSDs valueForKey:@"deltaT"];
            if (myTrack.dcRangeMax < myTrack.dcRangeMin)
            {myTrack.dcRangeMin = [NSNumber numberWithInteger:1]; myTrack.dcRangeMax = [NSNumber numberWithInteger:7]; [self AlertText:@"tau(f) must be greater than tau(i)" withPriority:3];
            }
            if ([myTrack.dcRangeMax integerValue] > distanceArray.count) {
                myTrack.dcRangeMax =[NSNumber numberWithInteger:distanceArray.count];
            }
            
            NSArray *diffusionResults = [self CalculateDiffusionCoefficientFromMSDs:distanceArray  withTaus:tauArray fromTau:[myTrack.dcRangeMin integerValue] toTau:[myTrack.dcRangeMax integerValue]];
            myTrack.diffusionCoefficient = [diffusionResults objectAtIndex:0];
            myTrack.dcIntercept = [diffusionResults objectAtIndex:1];
            myTrack.alpha = [diffusionResults objectAtIndex:2];
        }
    }
    [ProgressBarOutlet setAlphaValue:0.f];
}

-(float)CalculateMSDfromXs:(NSArray *)xArray andYs:(NSArray *)yArray withTau:(NSInteger)tau{
    NSArray *distanceArray = [[NSArray alloc] init];
    
    for (int t=0; t < (xArray.count - tau); t++) {
        float d2 = powf(([[xArray objectAtIndex:(t + tau)] floatValue] - [[xArray objectAtIndex:t] floatValue]), 2.0) + powf(([[yArray objectAtIndex:(t + tau)] floatValue] - [[yArray objectAtIndex:t] floatValue]), 2.0);
        distanceArray = [distanceArray arrayByAddingObject:[NSNumber numberWithFloat:d2]];
        }
    
    NSNumber *sum = [distanceArray valueForKeyPath:@"@sum.self"];
    return [sum floatValue] / xArray.count;
}

-(NSArray *)CalculateDiffusionCoefficientFromMSDs:(NSArray *)msdArray withTaus:(NSArray *)tauArray fromTau:(NSInteger)tInitial toTau:(NSInteger)tFinal{

    float tNumber = tFinal - tInitial + 1;
    tInitial = tInitial - 1;

    LinearRegression *myRegression = [[LinearRegression alloc] init];
    RegressionResult *myResult = [[RegressionResult alloc] init];
    
    NSIndexSet *DiffusionSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(tInitial, tNumber)];
    
    NSArray *msdArrayForCalc = [msdArray objectsAtIndexes:DiffusionSet];
    NSArray *dTArrayForCalc = [tauArray objectsAtIndexes:DiffusionSet];
    
    myResult = [myRegression calculateRegressionwithXs:dTArrayForCalc withYs:msdArrayForCalc];
    float slope = myResult.slope;
    float inter = myResult.intercept;
    float diffusion = slope / 4;
    
    
    LinearRegression *alphaRegression = [[LinearRegression alloc] init];
    RegressionResult *alphaResult = [[RegressionResult alloc] init];
    float logSlope = logf(diffusion * 4);
    
    NSArray *logTaus = [[NSArray alloc] init];
    for (NSNumber *eachTau in tauArray) {
        float logEachTau = logf([eachTau floatValue]);
        logTaus = [logTaus arrayByAddingObject:[NSNumber numberWithFloat:logEachTau]];
    }
    NSArray *logYs = [[NSArray alloc] init];
    for (NSNumber *eachMSD in msdArray) {
        float logMSD = logf([eachMSD floatValue]);
        float logY = logMSD - logSlope;
        logYs = [logYs arrayByAddingObject:[NSNumber numberWithFloat:logY]];
    }
    
    alphaResult = [alphaRegression calculateRegressionwithXs:logTaus withYs:logYs];
    float alpha = alphaResult.slope;
    
    NSArray *returnArray = [[NSArray alloc] init];
    returnArray = [returnArray arrayByAddingObject:[NSNumber numberWithFloat:diffusion]];
    returnArray = [returnArray arrayByAddingObject:[NSNumber numberWithFloat:inter]];
    returnArray = [returnArray arrayByAddingObject:[NSNumber numberWithFloat:alpha]];
    
    return returnArray;
}


-(IBAction)UpdateDrawCanvas:(id)sender {
    Experiment *myExp = [[ExperimentControllerOutlet selectedObjects] objectAtIndex:0];
    if([myExp.doesConstantlyCalculate integerValue] == 1) {
        [self RunCalculations:[TrackControllerOutlet selectedObjects]];
    }
    [self UpdateTrackBezierCanvas];
    [self UpdateGraphs];
}

- (void)UpdateGraphs{
    NSArray *spotArray = [SpotControllerOutlet arrangedObjects];
    NSIndexSet *spotIndexes = [SpotControllerOutlet selectionIndexes];
    NSArray *timeXs = [spotArray valueForKey:@"t"];
    NSArray *intensityYs = [spotArray valueForKey:@"i"];
    [self makeLineGraph:IntensityLinegraphOutlet withXs:timeXs withYs:intensityYs withSelectionIndexes:spotIndexes];

    NSArray *distYs = [spotArray valueForKey:@"distanceTo"];
    [self makeLineGraph:DistanceLinegraphOutlet withXs:timeXs withYs:distYs withSelectionIndexes:spotIndexes];
        
    Experiment *myExperiment = [[ExperimentControllerOutlet arrangedObjects] objectAtIndex:0];
    Track *myTrack = [[TrackControllerOutlet selectedObjects] objectAtIndex:0];
    NSArray *msdArray = [MSDControllerOutlet arrangedObjects];
    NSArray *msdXs = [msdArray valueForKey:@"deltaT"];
    NSArray *MSDYs = [msdArray valueForKey:@"distance"];
    [self makeLineGraph:MSDLinegraphOutlet withXs:msdXs withYs:MSDYs withSelectionIndexes:Nil];
    MSDLinegraphOutlet.redXYInitial = NSMakePoint(0, [myTrack.dcIntercept floatValue] * [myExperiment.timeScale floatValue]);
    MSDLinegraphOutlet.redXYFinal = NSMakePoint([myTrack.dcRangeMax floatValue] * [myExperiment.timeScale floatValue], ([myTrack.diffusionCoefficient floatValue] * 4 * [myTrack.dcRangeMax floatValue]) * [myExperiment.timeScale floatValue]);
    MSDLinegraphOutlet.hasRed = YES;
    MSDLinegraphOutlet.hasDotted = YES;
    MSDLinegraphOutlet.hasAlphaCurve = NO;
    if ([myTrack.alpha floatValue] > 0) {
        MSDLinegraphOutlet.hasAlphaCurve = YES;
        float theAlpha = [myTrack.alpha floatValue];
        float theSlope = [myTrack.diffusionCoefficient floatValue];
        float timeScale = [myExperiment.timeScale floatValue];
        
        NSArray *evaluatedAlphas = [[NSArray alloc] init];
        ///Make sure you only use the same MSD array for the alpha curve as you do for the MSD curve, and NOT the entire spot array///
        for (int i=0; i < msdArray.count; i++) {
            float thisT = [[timeXs objectAtIndex:i] floatValue] - [[timeXs objectAtIndex:0] floatValue];
            float thisTau = i * timeScale + timeScale;  //or use thisT instead of i ?  but doesn't compensate for discontinuities... hmm..
            float thisY = theSlope / 2 * powf(thisTau, theAlpha);
            evaluatedAlphas = [evaluatedAlphas arrayByAddingObject:[NSNumber numberWithFloat:thisY]];
        }
        
        MSDLinegraphOutlet.alphas = evaluatedAlphas;
    }
    MSDLinegraphOutlet.hasAlphaCurve = YES;

    
}

-(void)makeLineGraph:(LineGraph *)outlet withXs:(NSArray *)xValues withYs:(NSArray *)yValues withSelectionIndexes:(NSIndexSet *)indexes{
    
    if (indexes != nil) {
        NSInteger index = [indexes firstIndex];
        outlet.hasTimeSig = YES;
        outlet.timeSig = NSMakePoint(index + 1, 0);
        outlet.redWidth = [NSNumber numberWithInteger:indexes.count];
    }else{
        outlet.hasTimeSig = NO;
        outlet.redWidth = [NSNumber numberWithInteger:0];
    }
    
    outlet.xArray = xValues;
    outlet.yArray = yValues;
    [outlet setNeedsDisplay:YES];
}

- (IBAction)AdjustImage:(id)sender {
    [FrameControllerOutlet setSelectionIndex:[FrameControllerOutlet selectionIndex]];
}

- (IBAction)test3:(id)sender {
    Experiment *myExperiment = [[ExperimentControllerOutlet arrangedObjects] objectAtIndex:0];
    //NSArray *myTracks = [TrackControllerOutlet arrangedObjects];
    
    NSArray *myTracks = [EveryTrackControllerOutlet selectedObjects];
    if (myTracks.count < 2) {
        myTracks = [EveryTrackControllerOutlet arrangedObjects];
    }
    
    
    NSInteger max = 21;
    NSArray *allMSDs = [[NSArray alloc] init];
    
    for (Track *eachTrack in myTracks) {
        allMSDs = [allMSDs arrayByAddingObjectsFromArray:[eachTrack.msds allObjects]];
    }
    NSArray *allDistances = [[NSArray alloc] init];
    NSArray *allTimes = [[NSArray alloc] init];
    for (int i=0; i<max; i++) {
        NSNumber *deltaTime = [NSNumber numberWithFloat:(i * [myExperiment.timeScale floatValue])];
        NSPredicate *forAllDeltaTs = [NSPredicate predicateWithFormat:@"deltaT == %@",deltaTime];
        NSArray *thoseDistances = [allMSDs filteredArrayUsingPredicate:forAllDeltaTs];
        float meanDist = [[thoseDistances valueForKeyPath:@"@avg.distance"] floatValue];
        allDistances = [allDistances arrayByAddingObject:[NSNumber numberWithFloat:meanDist]];
        allTimes = [allTimes arrayByAddingObject:deltaTime];
    }
    
    NSInteger dcMax = 10;
    NSArray *resultArray = [self CalculateDiffusionCoefficientFromMSDs:allDistances withTaus:allTimes fromTau:1 toTau:dcMax];
    float allDC = [[resultArray objectAtIndex:0] floatValue];
    float allDCIntercept = [[resultArray objectAtIndex:1] floatValue];
    float allAlpha = [[resultArray objectAtIndex:2] floatValue];
    
    float xUnit = dcMax * [myExperiment.timeScale floatValue];
    
    [self makeLineGraph:TogetherMSDGraph withXs:allTimes withYs:allDistances withSelectionIndexes:Nil];
    
    TogetherMSDGraph.redXYInitial = NSMakePoint(0, allDCIntercept);
    TogetherMSDGraph.redXYFinal = NSMakePoint( xUnit, (allDC * 4 * xUnit));
    
    
    TogetherMSDGraph.hasRed = YES;
    TogetherMSDGraph.hasDotted = YES;
    
    
    NSArray *currentObjects = [EveryTrackControllerOutlet arrangedObjects];
    
    NSString *numberText = [NSString stringWithFormat:@"%lu tracks computed", [myTracks count]];
    [reportNumberOutlet setStringValue:numberText];
    
    NSString *diffusionText = [NSString stringWithFormat:@"Diffusion: \rset = %f \rmean = %f \rmin = %f \rmax = %f",
                               allDC,
                               [[myTracks valueForKeyPath:@"@avg.diffusionCoefficient"] floatValue],
                               [[myTracks valueForKeyPath:@"@min.diffusionCoefficient"] floatValue],
                               [[myTracks valueForKeyPath:@"@max.diffusionCoefficient"] floatValue]];
    [reportDiffusionOutlet setStringValue:diffusionText];
    
    NSString *alphaText = [NSString stringWithFormat:@"Alpha value of %.001f",allAlpha];
    [reportAlphaOutlet setStringValue:alphaText];
    
    
}

-(void)UpdateTrackBezierCanvas{
    Experiment *myExperiment = [[ExperimentControllerOutlet arrangedObjects] objectAtIndex:0];
    Preferences *myPrefs = [[PreferencesControllerOutlet arrangedObjects] objectAtIndex:0];
    float zoom = [myPrefs.zoomLevel floatValue];
    if (zoom <= 0) {
        zoom = 1.f;
    }
    float scale = [myExperiment.lengthScale floatValue];
    if (scale <=0) {
        scale = 1;
        [self UnitAlert];
    }
    float timescale = [myExperiment.timeScale floatValue];
    if (timescale <=0) {
        timescale = 1;
        [self UnitAlert];
    }
    
    
    
    NSArray *selectedTracks = [TrackControllerOutlet selectedObjects];
    if (selectedTracks.count == 1) {
    
    Track *myTrack = [selectedTracks objectAtIndex:0];
    
    NSInteger specificSpotID = [SpotControllerOutlet selectionIndex];
    
    Spot *specificSpot = [[SpotControllerOutlet arrangedObjects] objectAtIndex:specificSpotID];
    
    NSBezierPath *bezPath = [NSBezierPath bezierPath];
    NSArray *allSpots = [[myTrack spots] allObjects];
    NSSortDescriptor *sortSpotsbyT = [[NSSortDescriptor alloc] initWithKey: @"t" ascending: YES];
    NSArray *sortedSpots = [allSpots sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortSpotsbyT]];
    
    
    CGFloat firstX = [[[sortedSpots objectAtIndex:0] x] floatValue];
    CGFloat firstY = [[[sortedSpots objectAtIndex:0] y] floatValue];
    NSRect theBounds = TrackCanvasOutlet.bounds;
    float centerX = theBounds.size.width / 2;
    float centerY = theBounds.size.height / 2;
    
    [bezPath moveToPoint:NSMakePoint(centerX, centerY)];
    
    
    for (Spot *eachSpot in sortedSpots) {
        float theX = [eachSpot.x floatValue] - firstX;
        float theY = [eachSpot.y floatValue] - firstY;
        
        
        
        NSPoint spotPoint = NSMakePoint((theX * zoom) + centerX, (theY  * zoom + centerY));
        [bezPath lineToPoint:spotPoint];
    }
    
    NSPoint specificSpotPoint = NSMakePoint((([specificSpot.x floatValue] - firstX) * zoom) + centerX, (([specificSpot.y floatValue]- firstY)) * zoom + centerY);
    
        
        
    ///and also display the image
    
    NSArray *myImages = [FrameControllerOutlet arrangedObjects];
    NSPredicate *frameIndex = [NSPredicate predicateWithFormat:@"t == %d",[specificSpot.t integerValue]];
    NSArray *filteredImages = [myImages filteredArrayUsingPredicate:frameIndex];
    if ([filteredImages count] > 0) {
        Frame *myImage = [filteredImages objectAtIndex:0];
        NSURL *imageURL = [NSURL URLWithString:myImage.filename];
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithContentsOfURL:[NSURL URLWithString:myImage.filename]];
        //if (AutoContrastTrackImageOutlet.integerValue > 0) {
            TrackCanvasOutlet.actualImage = [TrackCanvasOutlet autoAdjustImageWithURL:imageURL];
        TrackCanvasOutlet.actulImageURL = imageURL;
        //}else{
         //   NSImage *myImageData = [[NSImage alloc] initWithContentsOfURL:imageURL];
         //   trackCanvasOutlet.actualImage = myImageData;
        //}
        TrackCanvasOutlet.imageRep = rep;
        
    }
        TrackCanvasOutlet.centeringPoint = NSMakePoint(firstX, firstY);
        TrackCanvasOutlet.zoom = zoom;
        TrackCanvasOutlet.scale = scale;
        TrackCanvasOutlet.thePath = bezPath;
        TrackCanvasOutlet.thePoint = specificSpotPoint;
        TrackCanvasOutlet.pathColor = [NSColor blueColor];
    }
    [TrackCanvasOutlet display];
}

-(void)UnitAlert{
    
    [NSApp beginSheet:ScaleWindowOutlet.window modalForWindow:MainViewOutlet.window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(void)AlertText:(NSString*)msg withPriority:(NSInteger)priority{
    
    NSColor *priorityColor = [NSColor blackColor];
    if (priority==1) {
        priorityColor = [NSColor greenColor];
    }else if (priority==2){
        priorityColor = [NSColor orangeColor];
    }else if (priority==3){
        priorityColor = [NSColor redColor];
    }
    [AlertMessageLabelOutlet setAlphaValue:1];
    [AlertMessageLabelOutlet setHidden:false];
    [AlertMessageLabelOutlet setTextColor:priorityColor];
    [AlertMessageLabelOutlet setStringValue:msg];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:5.0f];
    [[AlertMessageLabelOutlet animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
}


- (IBAction)CloseScaleWindow:(id)sender {
    [NSApp endSheet:ScaleWindowOutlet.window];
    [ScaleWindowOutlet.window orderOut:nil];
}


- (IBAction)UpdateClassifications:(id)sender{
    [self UpdateClassificationMenu];
}

- (void)UpdateClassificationMenu{
    NSArray *currentClasses = [ClassificationControllerOutlet arrangedObjects];
    
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    
    [appDelegate.ClassificationMenuOutlet removeAllItems];
    [appDelegate.ClassificationMenuOutlet setAutoenablesItems:NO];
    
    
    for (int i=0; i<currentClasses.count; i++) {
        Classification *eachClass = [currentClasses objectAtIndex:i];
        NSString *key = [NSString stringWithFormat:@"%d",(i + 1)];
        NSString *name = eachClass.name;
        if (name==nil) {name = @"Class";};
        NSMenuItem *eachMenu = [[NSMenuItem alloc] initWithTitle:name action:@selector(ClassificationChanged:) keyEquivalent:key];
        [eachMenu setEnabled:YES];
        [appDelegate.ClassificationMenuOutlet addItem:eachMenu];
        
    }
}

- (IBAction)FetchClassifications:(id)sender {
    NSString *className = [sender title];
    if ([className isEqualToString:@"All Tracks"]) {
        [TrackControllerOutlet setFilterPredicate:nil];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"classification == %@",className];
        [TrackControllerOutlet setFilterPredicate:predicate];
    }
}

- (IBAction)SelectImageStack:(id)sender {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:YES];
        [panel setCanCreateDirectories:YES];
        [panel setAllowsMultipleSelection:YES];
        [panel setPrompt:@"Select"];
        if([panel runModal]){
            Experiment *myExperiment = [[ExperimentControllerOutlet selectedObjects] objectAtIndex:0];
            if ([myExperiment.imageStack count] > 0) {
                [myExperiment removeImageStack:myExperiment.imageStack];
            }
            
            //get an array containing full filenames of all files & dirs
            NSArray *files = [panel URLs];
            NSURL *firstURL = [files objectAtIndex:0];
            NSString *imageName = [firstURL absoluteString];
            
            [ProgressBarOutlet setHidden:NO];
            [ProgressBarOutlet setMaxValue:files.count];
            [ProgressBarOutlet setDoubleValue:0];
            
            NSMutableSet *imageSet = [[NSMutableSet alloc] init];
            
            //import every image into a file
            for( int i=0; i < (files.count); i++){
                NSURL *file = [files objectAtIndex:i];
                
                Frame *thisImage = [FrameControllerOutlet newObject];
                thisImage.filename = [file absoluteString];
                thisImage.t = [NSNumber numberWithInt:i];
                [imageSet addObject:thisImage];
                [ProgressBarOutlet incrementBy:1];
                
            }
            [myExperiment addImageStack:imageSet];
            [ProgressBarOutlet setHidden:YES];
            
            Frame *thumnailImage = [[FrameControllerOutlet arrangedObjects] objectAtIndex:0];
            NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithContentsOfURL:[NSURL URLWithString:thumnailImage.filename]];
            
            myExperiment.imagePixelsX = [NSNumber numberWithFloat:[rep pixelsWide]];
            myExperiment.imagePixelsY = [NSNumber numberWithFloat:[rep pixelsHigh]];
            [myExperiment setImageFileFolder:imageName];
        }
    }


- (IBAction)NextTrack:(id)sender {
    NSInteger index = [TrackControllerOutlet selectionIndex];
    if (index < [[TrackControllerOutlet arrangedObjects] count] -1) {
        [TrackControllerOutlet setSelectionIndex:[TrackControllerOutlet selectionIndex] + 1];
    }
    Experiment *myExp = [[ExperimentControllerOutlet selectedObjects] objectAtIndex:0];

    if ([myExp.doesConstantlyCalculate integerValue] == 1) {
        [self RunCalculations:[TrackControllerOutlet selectedObjects]];
    }
    [self UpdateTrackBezierCanvas];
    [self UpdateGraphs];
}

- (IBAction)PreviousTrack:(id)sender {
    NSInteger index = [TrackControllerOutlet selectionIndex];
    if (index > 0) {
            [TrackControllerOutlet setSelectionIndex:[TrackControllerOutlet selectionIndex] - 1];
    }
    Experiment *myExp = [[ExperimentControllerOutlet selectedObjects] objectAtIndex:0];

    if ([myExp.doesConstantlyCalculate integerValue] == 1) {
        [self RunCalculations:[TrackControllerOutlet selectedObjects]];
    }
    [self UpdateTrackBezierCanvas];
    [self UpdateGraphs];
}

- (IBAction)NextPoint:(id)sender {
    NSInteger index = [SpotControllerOutlet selectionIndex];
    if (index < [[SpotControllerOutlet arrangedObjects] count] - 1) {
        [SpotControllerOutlet setSelectionIndex:[SpotControllerOutlet selectionIndex] + 1];
    }
    [self UpdateTrackBezierCanvas];
    [self UpdateGraphs];
}

- (IBAction)PreviousPoint:(id)sender {
    NSInteger index = [SpotControllerOutlet selectionIndex];
    if (index > 0) {
        [SpotControllerOutlet setSelectionIndex:[SpotControllerOutlet selectionIndex] - 1];
    }
    [self UpdateTrackBezierCanvas];
    [self UpdateGraphs];
}

- (IBAction)ZoomOut:(id)sender {
    Preferences *myPreferences = [[PreferencesControllerOutlet selectedObjects] objectAtIndex:0];
    float zoom = ([myPreferences.zoomLevel floatValue] * 0.5 );
    [myPreferences setZoomLevel:[NSNumber numberWithFloat:zoom]];
    [self UpdateTrackBezierCanvas];
}

- (IBAction)ZoomIn:(id)sender {
    Preferences *myPreferences = [[PreferencesControllerOutlet selectedObjects] objectAtIndex:0];
    float zoom = ([myPreferences.zoomLevel floatValue] * 2);
    [myPreferences setZoomLevel:[NSNumber numberWithFloat:zoom]];
    [self UpdateTrackBezierCanvas];
}
- (IBAction)FilterBy:(id)sender {
    NSString *name = [[sender selectedItem] title];
    NSString *filterBy = [sender sortKey];
    NSInteger index = [sender indexOfSelectedItem];
    NSPredicate *currentPredicate = [EveryTrackControllerOutlet filterPredicate];
    if (index != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",filterBy, name];
        NSArray *predicateArray = [NSArray arrayWithObjects:currentPredicate,predicate, nil];
        NSCompoundPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
        
        [EveryTrackControllerOutlet setFilterPredicate:predicates];
    }else{
        [EveryTrackControllerOutlet setFilterPredicate:currentPredicate];
    }
}

- (IBAction)ClearFilter:(id)sender {
    [EveryTrackControllerOutlet setFilterPredicate:nil];
}


- (IBAction)updateUnits:(id)sender {
    [TrackTableOutlet reloadData];
    [AnalysisTableOutlet reloadData];
    [SpotTableOutlet reloadData];
}
- (IBAction)ExportDisplayedData:(id)sender {
    NSArray *displayedTracks = [EveryTrackControllerOutlet arrangedObjects];
    
    NSString *outputData = @"experiment\tcondition\tclassification\tid\tlength\tdiffusion coefficient\talpha\tmaxDistance (um)\tminIntensity\tavgIntensity\tmaxIntensity";
    
    for (Track *eachTrack in displayedTracks) {
        outputData = [outputData stringByAppendingFormat:@"%@\t%@\t%@\t%@\t%lu\t%@\t%@\t%.0001f\t%@\t%@\t%@\t\r\n",
                      eachTrack.experiment.name,
                      eachTrack.experiment.condition,
                      eachTrack.classification,
                      eachTrack.id,
                      (unsigned long)[eachTrack.spots count],
                      eachTrack.diffusionCoefficient,
                      eachTrack.alpha,
                    ([eachTrack.maxDistance floatValue] * [eachTrack.experiment.lengthScale floatValue]),
                      eachTrack.minIntensity,
                      eachTrack.avgIntensity,
                      eachTrack.maxIntensity];
    }
    
    NSString *exptName = [[[NSDocumentController sharedDocumentController] currentDocument] displayName];
    
    [self ExportToFile:outputData withName:exptName];
}



- (IBAction)ExportTrack:(id)sender {
    NSArray *displayedSpots = [SpotControllerOutlet arrangedObjects];
    Track *selectedTrack = [[TrackControllerOutlet selectedObjects] objectAtIndex:0];
    NSString *outputData = @"id\tt\tx\ty\ti\tdistance (um)\r\n";
    
    for (Spot *eachSpot in displayedSpots) {
        outputData = [outputData stringByAppendingFormat:@"%@\t%@\t%@\t%@\t%@\t%@\r\n",
                      eachSpot.track.id,
                      eachSpot.t,
                      eachSpot.x,
                      eachSpot.y,
                      eachSpot.i,
                      eachSpot.distanceTo];
    }
    NSString *trackName = [NSString stringWithFormat:@"%@ - Track %@",selectedTrack.experiment.name,selectedTrack.id];
    [self ExportToFile:outputData withName:trackName];
}
- (IBAction)ExportMSDs:(id)sender {
    NSArray *displayedMSDs = [MSDControllerOutlet arrangedObjects];
    Track *selectedTrack = [[TrackControllerOutlet selectedObjects] objectAtIndex:0];
    NSString *outputData = @"tau\tdistance\r\n";
    
    for (MSD *eachMSD in displayedMSDs) {
        outputData = [outputData stringByAppendingFormat:@"%@\t%@\r\n",
                      eachMSD.deltaT,
                      eachMSD.distance];
    }
    NSString *trackName = [NSString stringWithFormat:@"%@ - Track %@ MSDs",selectedTrack.experiment.name,selectedTrack.id];
    [self ExportToFile:outputData withName:trackName];
}

- (IBAction)ExportTrackSummary:(id)sender {
    Track *selectedTrack = [[TrackControllerOutlet selectedObjects] objectAtIndex:0];
    Experiment *theExpt = selectedTrack.experiment;
    NSArray *displayedSpots = [SpotControllerOutlet arrangedObjects];
    NSString *outputData = [NSString stringWithFormat:@"Summary for Track %@ from Experiment %@",selectedTrack.id,theExpt.name];
    
    NSString *exptSummaryData = [NSString stringWithFormat:@"name\tcondition\tlengthscale\ttimescale\r\n%@\t%@\t%@\t%@",
                                 theExpt.name,
                                 theExpt.condition,
                                 theExpt.lengthScale,
                                 theExpt.timeScale];
    outputData = [outputData stringByAppendingFormat:@"\r\n\r\n%@",exptSummaryData];
    
    NSString *trackSummary = [NSString stringWithFormat:@"length\tclassification\tdiffusion coefficient\talpha\tmaxDistance (um)\tminIntensity\tavgIntensity\tmaxIntensity\r\n%lu\t%@\t%@\t%@\t%f\t%@\t%@\t%@",
                              (unsigned long)[selectedTrack.spots count],
                              selectedTrack.classification,
                              selectedTrack.diffusionCoefficient,
                              selectedTrack.alpha,
                              ([selectedTrack.maxDistance floatValue] * [theExpt.lengthScale floatValue]),
                              selectedTrack.minIntensity,
                              selectedTrack.avgIntensity,
                              selectedTrack.maxIntensity];
    outputData = [outputData stringByAppendingFormat:@"\r\n\r\n%@",trackSummary];

    
    
    NSString *nextData = @"The Track\r\nid\tt\tx\ty\ti\tdistance (um)\r\n";
    for (Spot *eachSpot in displayedSpots) {
        nextData = [nextData stringByAppendingFormat:@"%@\t%@\t%@\t%@\t%@\t%@\r\n",
                      eachSpot.track.id,
                      eachSpot.t,
                      eachSpot.x,
                      eachSpot.y,
                      eachSpot.i,
                      eachSpot.distanceTo];
    }
    outputData = [outputData stringByAppendingFormat:@"\r\n\r\n%@",nextData];
    
    NSString *MSDData = @"MSDs:\r\ndeltaT\tMSD\r\n";
    for (MSD *eachMSD in selectedTrack.msds) {
        MSDData = [MSDData stringByAppendingFormat:@"%@\t%@\r\n",
                      eachMSD.deltaT,
                      eachMSD.distance];
    }
    outputData = [outputData stringByAppendingFormat:@"\r\n\r\n%@",MSDData];
    
    
    
    
    NSString *trackName = [NSString stringWithFormat:@"%@ - Track %@ Summary",theExpt.name,selectedTrack.id];
    [self ExportToFile:outputData withName:trackName];
}

- (IBAction)ExportTracks:(id)sender {
    NSArray *displayedTracks = [TrackControllerOutlet arrangedObjects];
    NSString *outputData = @"id\tt\tx\ty\ti\tdistance (px)\r\n";
    Experiment *theExpt = [[ExperimentControllerOutlet selectedObjects] objectAtIndex:0];
    
    for (Track *eachTrack in displayedTracks) {
        
        NSArray *allSpots = [eachTrack.spots allObjects];
        NSSortDescriptor* sortByT = [[NSSortDescriptor alloc] initWithKey: @"t" ascending: YES];
        allSpots = [allSpots sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByT]];
        
        for (Spot *eachSpot in allSpots) {
            outputData = [outputData stringByAppendingFormat:@"%@\t%@\t%@\t%@\t%@\t%@\r\n",
                          eachSpot.track.id,
                          eachSpot.t,
                          eachSpot.x,
                          eachSpot.y,
                          eachSpot.i,
                          eachSpot.distanceTo];
        }
    }
    NSString *trackName = [NSString stringWithFormat:@"%@ Tracks",theExpt.name];
    [self ExportToFile:outputData withName:trackName];
}

- (IBAction)ExportTrackSummaries:(id)sender {
    NSArray *displayedTracks = [TrackControllerOutlet arrangedObjects];
    Experiment *theExpt = [[ExperimentControllerOutlet selectedObjects] objectAtIndex:0];
    NSString *outputData = @"experiment\tcondition\tid\tlength\tclassification\tdiffusion coefficient\talpha\tmaxDistance (um)\tminIntensity\tavgIntensity\tmaxIntensity\r\n";
    
    
    
    for (Track *eachTrack in displayedTracks) {
            outputData = [outputData stringByAppendingFormat:@"%@\t%@\t%@\t%lu\t%@\t%@\t%@\t%.001f\t%@\t%@\t%@\r\n",
                          eachTrack.experiment.name,
                          eachTrack.experiment.condition,
                          eachTrack.id,
                          [eachTrack.spots count],
                          eachTrack.classification,
                          eachTrack.diffusionCoefficient,
                          eachTrack.alpha,
                          ([eachTrack.maxDistance floatValue] * [eachTrack.experiment.lengthScale floatValue]),
                          eachTrack.minIntensity,
                          eachTrack.avgIntensity,
                          eachTrack.maxIntensity];
    }
    NSString *trackName = [NSString stringWithFormat:@"%@ Track Summaries",theExpt.name];
    [self ExportToFile:outputData withName:trackName];
    
}

- (IBAction)ExportIvTGraph:(id)sender {
    NSData *data = [IntensityLinegraphOutlet dataWithPDFInsideRect:IntensityLinegraphOutlet.bounds];
    Track *myTrack = [[TrackControllerOutlet selectedObjects] objectAtIndex:0];
    NSString *name = [NSString stringWithFormat:@"%@ - Track %@ Intensity vs Time",myTrack.experiment.name,myTrack.id];
    [self ExportToPDF:data withName:name];
}

- (IBAction)ExportTracksAsDat:(id)sender {
    NSArray *displayedTracks = [TrackControllerOutlet arrangedObjects];
    NSString *outputData = @"";
    Experiment *theExpt = [[ExperimentControllerOutlet selectedObjects] objectAtIndex:0];
    
    for (Track *eachTrack in displayedTracks) {
        
        NSArray *allSpots = [eachTrack.spots allObjects];
        NSSortDescriptor* sortByT = [[NSSortDescriptor alloc] initWithKey: @"t" ascending: YES];
        allSpots = [allSpots sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByT]];
        
        for (Spot *eachSpot in allSpots) {
            outputData = [outputData stringByAppendingFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\r\n",
                          eachSpot.x,
                          eachSpot.y,
                          eachSpot.i,
                          @"0",
                          @"0",
                          eachSpot.t,
                          eachSpot.track.id,
                          @"0",
                          @"0",
                          @"0"];
        }
    }
    NSString *trackName = [NSString stringWithFormat:@"%@ Tracks.dat",theExpt.name];
    [self ExportToFile:outputData withName:trackName];
    
    
    
    /*
     
     myImportData.indexID = [NSNumber numberWithInteger:6];
     myImportData.indexT = [NSNumber numberWithInteger:5];
     myImportData.indexX = [NSNumber numberWithInteger:0];
     myImportData.indexY = [NSNumber numberWithInteger:1];
     myImportData.indexI = [NSNumber numberWithInteger:2];
     myImportData.rowDelim = @"\r\n";
     myImportData.colDelim = @"\t";
     
     */
    
}


-(void)ExportToPDF:(NSData *)data withName:(NSString *)docName{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:docName];
    NSInteger ret = [panel runModal];
    if (ret == NSFileHandlingPanelOKButton) {
        NSURL *fileURL = [[panel URL] URLByAppendingPathExtension:@"pdf"];
        [data writeToURL:fileURL atomically:NO];
    }
    [self AlertText:@"Graph successfully exported" withPriority:1];
}


-(void)ExportToFile:(NSString *)data withName:(NSString *)docName{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:docName];
    NSInteger ret = [panel runModal];
    if (ret == NSFileHandlingPanelOKButton) {
        NSURL *fileURL = [[panel URL] URLByAppendingPathExtension:@"csv"];
        [data writeToURL:fileURL atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
    [self AlertText:@"Document successfully exported" withPriority:1];
    
    
}



- (IBAction)ImageTest:(id)sender {
    Frame *thisFrame = [[FrameControllerOutlet selectedObjects] objectAtIndex:0];
    
    NSImage *thisImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:thisFrame.filename]];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepsWithContentsOfURL:[NSURL URLWithString:thisFrame.filename]];
    
    
    NSRect rect      = NSZeroRect;
    rect.size = thisImage.size;
    CGImageRef imageRef = [thisImage CGImageForProposedRect:&rect context:[NSGraphicsContext currentContext] hints:nil];
    CFDataRef rawData = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));

    NSInteger trackKind = [TrackKindTabViewOutlet indexOfTabViewItem:[TrackKindTabViewOutlet selectedTabViewItem]];
 
    
    //NSInteger threshhold =  [ThreshholdSliderOutlet integerValue];
    //threshhold = 220;
    //////LOTS OF MAJOR WORK/////
    ///// CAN WE GET THIS TO A UInt16 that doesn't crash!?//////
  //  UInt16 *buffer = (UInt16 *) CFDataGetBytePtr(rawData);
    /// so call it directly rather than point...
    
    
    NSInteger box = [BoxSizeOutlet integerValue];
    //NSInteger length = CFDataGetLength(rawData);
    NSInteger intense[5000];
    NSInteger count = 0;
    //NSInteger intensities[5000];
    //UInt8 *buffer = (UInt8 *) CFDataGetBytePtr(rawData);
    
    
    ///search intelligently for boxes
    NSInteger xt = 0;
    NSInteger xb = 0;
    NSInteger yt = 0;
    NSInteger yb = 0;
    NSInteger cent = 0;
    NSInteger corn = 0;
    NSInteger dif = [ToleranceOutlet integerValue];
    NSInteger half = floorf(box / 2) + 1;
    
    
    NSInteger scale = 512;
    NSInteger ref = 0;
    
    for (int i=0; i<(scale - box) - 1; i++) {
        for (int j=0; j<(scale - box) - 1; j++) {
            ref = j*scale + i;
            
            xt = ((UInt16 *)CFDataGetBytePtr(rawData))[ref];
            yt = ((UInt16 *)CFDataGetBytePtr(rawData))[ref + box];
            xb = ((UInt16 *)CFDataGetBytePtr(rawData))[ref + box * scale];
            yb = ((UInt16 *)CFDataGetBytePtr(rawData))[ref + box * scale + box];
            cent = ((UInt16 *)CFDataGetBytePtr(rawData))[ref + half * scale + half];
            
            corn = (xt + yt + xb + yt ) / 4;
            if ((cent - corn) > dif) {
                intense[count] = ref + half * scale + half;
                i = i + half;
                if (i>(scale-box)){
                    i = scale - box - 1;
                }
                count ++;
            }
        }
    }
    CFRelease(rawData);
    
    
    
    
    
    
    
    
    ///just find the strongest
   // for(int i=0; i<(length / 2); i++)
    //{
        //NSInteger intensity = ((UInt16 *)CFDataGetBytePtr(rawData))[i];
        //if (intensity>threshhold) {
        //    if (count<5000) {
        //        intense[count] = i;
        //        intensities[count] = intensity;
        //        count++;
        //    }
       // }
    //}
    
   // NSInteger sumI = 0;
   // for (int j=0; j<count; j++) {
    //    sumI += intensities[j];
    //}
    //NSInteger meanMaxI = floorf(sumI / count);
    
    NSArray *spotArray = [[NSArray alloc] init];
    
    
    
    
    
    NSInteger radius = half;
    
    

    rawData = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));

    NSArray *finalCentroids = [[NSArray alloc] init];
    
    for (int x=0; x<count; x++) {
        long actual = intense[x];
        long ycord = floorf(actual / 512);
        long xcord = actual - (512 * ycord);
        NSPoint eachPoint = NSMakePoint(xcord, ycord);
        float estimatedPointX = eachPoint.x;
        float estimatedPointY = eachPoint.y;
        NSInteger iterations = 200;
        
 
        float numeratorXSum = 0;
        float numeratorYSum = 0;
        float denominatorSum = 0;
        float finalDenominatorSum = 0;
        
        for (NSInteger z=0; z<iterations; z++) {
            numeratorXSum = 0;
            numeratorYSum = 0;
            denominatorSum = 0;
            finalDenominatorSum = 0;
            
            for (int k=-3; k<4; k++) {
                for (int j=-3; j<4; j++) {
                    NSPoint thisPoint = NSMakePoint(eachPoint.x + k, eachPoint.y + j);
                    
                    float expGaus = [[self ExpectedGaussianWithWidth:box givenEstimateX:estimatedPointX andEstimateY:estimatedPointY fromPixel:eachPoint] floatValue];
                    NSInteger imageLoc = (actual + k + (scale * j));
                    NSInteger actualIntensity = ((UInt16 *)CFDataGetBytePtr(rawData))[imageLoc];
                    
                    numeratorXSum = numeratorXSum + (thisPoint.x * actualIntensity * expGaus);
                    numeratorYSum = numeratorYSum + (thisPoint.y * actualIntensity * expGaus);
                    denominatorSum = denominatorSum + (actualIntensity * expGaus);
                    finalDenominatorSum = finalDenominatorSum + (expGaus * expGaus);
                }
            }
            

            
            float NewEstimatedPointX = numeratorXSum / denominatorSum;
            float NewEstimatedPointY = numeratorYSum / denominatorSum;
            
            if (NewEstimatedPointX == estimatedPointX && NewEstimatedPointY == estimatedPointY) {
                z = iterations;
            }else{
                estimatedPointY = NewEstimatedPointY;
                estimatedPointX = NewEstimatedPointX;
            }
         }
    
        
        finalCentroids = [finalCentroids arrayByAddingObject:[NSNumber numberWithFloat:estimatedPointX]];
        finalCentroids = [finalCentroids arrayByAddingObject:[NSNumber numberWithFloat:estimatedPointY]];
        
        
        NSRect rect = NSMakeRect(estimatedPointX - half + 2, estimatedPointY - half + 1, box, box);
        //rect = NSMakeRect(eachPoint.x - half + 1, eachPoint.y - half + 1, box, box);
        NSBezierPath *eachCircle = [NSBezierPath bezierPath];
        [eachCircle appendBezierPathWithOvalInRect:rect];
        spotArray = [spotArray arrayByAddingObject:eachCircle];
    }
    CFRelease(rawData);
    
    NSNumber *exposureValue = [NSNumber numberWithFloat:[ExposureSliderOutlet floatValue]];
    NSNumber *contrastValue = [NSNumber numberWithFloat:[ContrastSliderOutlet floatValue]];
    //exposureValue = [NSNumber numberWithFloat:6.5];
    //contrastValue = [NSNumber numberWithFloat:1.15];


    CIContext *context = [[CIContext alloc] init];
    CIImage *image = [CIImage imageWithContentsOfURL:[NSURL URLWithString:thisFrame.filename]];

    CIFilter *controlsFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [controlsFilter setValue:image forKey:kCIInputImageKey];
    [controlsFilter setValue:exposureValue forKey:@"inputEV"];
    CIImage *exposed = [controlsFilter valueForKey:@"outputImage"];
    
    CIFilter *contrastFilter = [CIFilter filterWithName:@"CIColorControls"];
    [contrastFilter setDefaults];
    [contrastFilter setValue:exposed forKey:@"inputImage"];
    [contrastFilter setValue:contrastValue forKey:@"inputContrast"];
    CIImage *outputImage = [contrastFilter valueForKey:@"outputImage"];

    

    CGImageRef cgImages = [context createCGImage:outputImage fromRect:[outputImage extent]];
    NSImage *newImage = [[NSImage alloc] initWithCGImage:cgImages size:NSZeroSize];
    
    
    
    ImageOutlet.actualImage = newImage;
    ImageOutlet.spots = spotArray;
    [ImageOutlet display];
    
    
    
    
}

-(NSNumber *)ExpectedGaussianWithWidth:(NSInteger)width givenEstimateX:(float)estimateX andEstimateY:(float)estimateY fromPixel:(NSPoint)pixel{
    
    float n = expf( - powf(pixel.x - estimateX, 2) / powf(2 * width, 2) - powf(pixel.y - estimateY, 2) / powf(2 * width, 2));
    return [NSNumber numberWithFloat:n];

}

         
         
         
@end









@implementation inSpaceUnits : NSValueTransformer
+(BOOL)allowsReverseTransformation{
    return YES;
}
- (id)reverseTransformedValue:(id)value{
    DocDelegate *myDelegate = [[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate];
    Preferences *myPrefs = [[myDelegate.PreferencesControllerOutlet arrangedObjects] objectAtIndex:0];
    if ([myPrefs.usesNaturalUnits integerValue]==1) {
        Experiment *myExpt = [[myDelegate.ExperimentControllerOutlet arrangedObjects] objectAtIndex:0];
        float scale = [myExpt.lengthScale floatValue];
        NSNumber *scaled = [NSNumber numberWithFloat:([value floatValue] / scale)];
        return scaled;
    }
    return value;
}
- (id)transformedValue:(id)value{
    DocDelegate *myDelegate = [[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate];
    Preferences *myPrefs = [[myDelegate.PreferencesControllerOutlet arrangedObjects] objectAtIndex:0];
    if ([myPrefs.usesNaturalUnits integerValue]==1) {
        Experiment *myExpt = [[myDelegate.ExperimentControllerOutlet arrangedObjects] objectAtIndex:0];
        float scale = [myExpt.lengthScale floatValue];
        NSNumber *scaled = [NSNumber numberWithFloat:([value floatValue] * scale)];
        return scaled;
    }
    return value;
}
@end

@implementation inTimeUnits : NSValueTransformer
+(BOOL)allowsReverseTransformation{
    return YES;
}
- (id)reverseTransformedValue:(id)value{
    DocDelegate *myDelegate = [[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate];
    Preferences *myPrefs = [[myDelegate.PreferencesControllerOutlet arrangedObjects] objectAtIndex:0];
    if ([myPrefs.usesNaturalUnits integerValue]==1) {
        Experiment *myExpt = [[myDelegate.ExperimentControllerOutlet arrangedObjects] objectAtIndex:0];
        float scale = [myExpt.timeScale floatValue];
        NSNumber *scaled = [NSNumber numberWithFloat:([value floatValue] / scale)];
        return scaled;
    }
    return value;
}
- (id)transformedValue:(id)value{
    DocDelegate *myDelegate = [[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate];
    Preferences *myPrefs = [[myDelegate.PreferencesControllerOutlet arrangedObjects] objectAtIndex:0];
    if ([myPrefs.usesNaturalUnits integerValue]==1) {
        Experiment *myExpt = [[myDelegate.ExperimentControllerOutlet arrangedObjects] objectAtIndex:0];
        float scale = [myExpt.timeScale floatValue];
        NSNumber *scaled = [NSNumber numberWithFloat:([value floatValue] * scale)];
        return scaled;
    }
    return value;
}
@end

@implementation arrayFromSet : NSValueTransformer
+(BOOL)allowsReverseTransformation{
    return NO;
}
- (id)transformedValue:(id)value{
    NSArray *array = [value allObjects];
    return array;
}
@end

@implementation arrayFromSets : NSValueTransformer
+(BOOL)allowsReverseTransformation{
    return NO;
}
- (id)transformedValue:(id)value{
    NSArray *wholeArray = [[NSArray alloc] init];
    for (NSSet *eachSet in value) {
        wholeArray = [wholeArray arrayByAddingObjectsFromArray:[eachSet allObjects]];
    }
    return wholeArray;
}
@end
@implementation toPredicate : NSValueTransformer
+(BOOL)allowsReverseTransformation{
    return NO;
}
- (id)transformedValue:(id)value{
    NSArray *predicateArray = [[NSArray alloc] init];
    for (NSNumber *each in value) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"@classification.name == %ln",each];
        predicateArray = [predicateArray arrayByAddingObject:predicate];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"classification.index == %@",[NSNumber numberWithInteger:1]];
    
    return predicate;
}
@end
@implementation imageFromClassification : NSValueTransformer
+(BOOL)allowsReverseTransformation{
    return NO;
}
- (id)transformedValue:(id)value{
    NSArray *classes =[[[[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate] ClassificationControllerOutlet] arrangedObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",value];
    NSArray *fetched =[classes filteredArrayUsingPredicate:predicate];
    
    NSImage *theIcon = [NSImage imageNamed:@"NSStatusNone"];
    if (fetched.count != 0) {
        Classification *myClass = [[classes filteredArrayUsingPredicate:predicate] objectAtIndex:0];
        theIcon = [NSImage imageNamed:myClass.icon];
    }
    return theIcon;
}
@end

@implementation charToName : NSValueTransformer
+(BOOL)allowsReverseTransformation{
    return YES;
}
- (id)transformedValue:(id)value{
    NSString *outputString = value;
    
    outputString =[outputString stringByReplacingOccurrencesOfString:@"\r" withString:@"<return>"];
    outputString =[outputString stringByReplacingOccurrencesOfString:@"\n" withString:@"<newline>"];
    outputString =[outputString stringByReplacingOccurrencesOfString:@"\t" withString:@"<tab>"];
    return outputString;
}
- (id)reverseTransformedValue:(id)value{
    NSString *outputString = value;
    outputString =[outputString stringByReplacingOccurrencesOfString:@"<return>" withString:@"\r"];
    outputString =[outputString stringByReplacingOccurrencesOfString:@"<newline>" withString:@"\n"];
    outputString =[outputString stringByReplacingOccurrencesOfString:@"<tab>" withString:@"\t"];
    return outputString;
}
@end


@implementation classList : NSValueTransformer
+(BOOL)allowsReverseTransformation{
    return NO;
}
- (id)transformedValue:(id)value{
    
    NSArray *theList = [NSArray arrayWithObject:@"All Tracks"];
    theList = [theList arrayByAddingObjectsFromArray:value];
    return theList;
}
@end


