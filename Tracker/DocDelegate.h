//
//  DocDelegate.h
//  Tracker2
//
//  Created by Justin Farlow on 9/20/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageCanvas.h"
#import "Track.h"

@interface DocDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) NSArray *trackFilterArray;

@property (assign) IBOutlet NSWindow *window;

- (void)didFinishLaunching:(NSNotification *)aNotification;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedDocObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedDocObjectContext;

@property (weak) IBOutlet NSArrayController *ExperimentControllerOutlet;
@property (weak) IBOutlet NSArrayController *TrackControllerOutlet;
@property (weak) IBOutlet NSArrayController *SpotControllerOutlet;
@property (weak) IBOutlet NSArrayController *MSDControllerOutlet;
@property (weak) IBOutlet NSArrayController *ClassificationControllerOutlet;
@property (weak) IBOutlet NSArrayController *PreferencesControllerOutlet;
@property (weak) IBOutlet NSArrayController *FrameControllerOutlet;
@property (weak) IBOutlet NSArrayController *EveryTrackControllerOutlet;




@property (weak) IBOutlet ImageCanvas *TrackCanvasOutlet;
@property (weak) IBOutlet NSTextField *AlertMessageLabelOutlet;

///Menu Options
- (IBAction)ChooseUnits:(id)sender;
- (IBAction)InfoWindow:(id)sender;
@property (weak) IBOutlet NSSegmentedCell *UnitsOfChoiceOutlet;

@property (weak) IBOutlet NSView *InfoWindowOutlet;


/////Tab Menu
@property (weak) IBOutlet NSTabView *TabbedViewOutlet;
@property (weak) IBOutlet NSSegmentedControl *TabViewButtonOutlet;

///Track Tab Objects
@property (weak) IBOutlet LineGraph *DistanceLinegraphOutlet;
@property (weak) IBOutlet LineGraph *IntensityLinegraphOutlet;
@property (weak) IBOutlet LineGraph *MSDLinegraphOutlet;
@property (weak) IBOutlet LineGraph *TogetherMSDGraph;
@property (weak) IBOutlet NSTabView *TrackKindTabViewOutlet;


- (IBAction)SelectImageStack:(id)sender;



//////Drawing
- (IBAction)UpdateDrawCanvas:(id)sender;
-(void)UpdateTrackBezierCanvas;
-(void)UpdateGraphs;
-(void)makeLineGraph:(LineGraph *)outlet withXs:(NSArray *)xValues withYs:(NSArray *)yValues withSelectionIndexes:(NSIndexSet *)indexes;
- (IBAction)AdjustImage:(id)sender;
@property (weak) IBOutlet FrameCanvas *ImageOutlet;

- (IBAction)test3:(id)sender;


/////Calculations
- (IBAction)CalculateCurrentTracks:(id)sender;
- (IBAction)CalculateAllTracks:(id)sender;


-(void)RunCalculations:(NSArray *)trackArray;
-(float)CalculateMSDfromXs:(NSArray *)xArray andYs:(NSArray *)yArray withTau:(NSInteger)tau;
-(NSArray *)CalculateDiffusionCoefficientFromMSDs:(NSArray *)msdArray withTaus:(NSArray *)tauArray fromTau:(NSInteger)tInitial toTau:(NSInteger)tFinal;
@property (weak) IBOutlet NSProgressIndicator *ProgressBarOutlet;
@property (weak) IBOutlet NSPopUpButton *MaxTauOutlet;



////Classification changes
- (IBAction)UpdateClassifications:(id)sender;
- (IBAction)FetchClassifications:(id)sender;
- (void)UpdateClassificationMenu;

///Alert MEssages
-(void)AlertText:(NSString*)msg withPriority:(NSInteger)priority;
-(void)UnitAlert;
@property (weak) IBOutlet NSView *MainViewOutlet;
@property (weak) IBOutlet NSView *ScaleWindowOutlet;
- (IBAction)CloseScaleWindow:(id)sender;

/////image playing
@property (weak) IBOutlet NSSlider *ContrastSliderOutlet;
@property (weak) IBOutlet NSButton *UseContrastSliderOutlet;
@property (weak) IBOutlet NSSlider *ExposureSliderOutlet;
@property (weak) IBOutlet NSSlider *BlackPointSliderOutlet;
@property (weak) IBOutlet NSSlider *WhitePointSliderOutlet;



- (IBAction)NextTrack:(id)sender;
- (IBAction)PreviousTrack:(id)sender;
- (IBAction)NextPoint:(id)sender;
- (IBAction)PreviousPoint:(id)sender;

- (IBAction)ZoomOut:(id)sender;
- (IBAction)ZoomIn:(id)sender;

////filter buttons
- (IBAction)FilterBy:(id)sender;


/////Report Labels
@property (weak) IBOutlet NSTextField *reportNumberOutlet;
@property (weak) IBOutlet NSTextField *reportDiffusionOutlet;
@property (weak) IBOutlet NSTextField *reportAlphaOutlet;

- (IBAction)updateUnits:(id)sender;
@property (weak) IBOutlet NSTableView *SpotTableOutlet;
@property (weak) IBOutlet NSTableView *TrackTableOutlet;
@property (weak) IBOutlet NSTableView *AnalysisTableOutlet;


///////EXPORTING
- (IBAction)ExportTrack:(id)sender;
- (IBAction)ExportMSDs:(id)sender;
- (IBAction)ExportTrackSummary:(id)sender;
- (IBAction)ExportTracks:(id)sender;
- (IBAction)ExportDisplayedData:(id)sender;
- (IBAction)ExportTrackSummaries:(id)sender;
- (IBAction)ExportIvTGraph:(id)sender;



-(void)ExportToFile:(NSString *)data withName:(NSString *)docName;
-(void)ExportToPDF:(NSData *)data withName:(NSString *)docName;

- (IBAction)ImageTest:(id)sender;
@property (weak) IBOutlet NSSlider *ThreshholdSliderOutlet;
@property (weak) IBOutlet NSTextField *BoxSizeOutlet;
@property (weak) IBOutlet NSTextField *ToleranceOutlet;

-(NSNumber *)ExpectedGaussianWithWidth:(NSInteger)width givenEstimateX:(float)estimateX andEstimateY:(float)estimateY fromPixel:(NSPoint)pixel;

@end







/////VALUE TRANSFORMERS
@interface inSpaceUnits : NSValueTransformer
@end
@interface inTimeUnits : NSValueTransformer
@end
@interface arrayFromSet : NSValueTransformer
@end
@interface arrayFromSets : NSValueTransformer
@end
@interface toPredicate : NSValueTransformer
@end
@interface imageFromClassification : NSValueTransformer
@end
@interface charToName : NSValueTransformer
@end
@interface classList : NSValueTransformer
@end