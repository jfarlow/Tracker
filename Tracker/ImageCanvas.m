//
//  ImageCanvas.m
//  Tracker
//
//  Created by Justin Farlow on 4/8/13.
//  Copyright (c) 2013 UCSF. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CIFilter.h>
#import <math.h>
#import "AppDelegate.h"
#import "ImageCanvas.h"
#import "Experiment.h"
#import "Frame.h"
#import "DocDelegate.h"
#import "Document.h"
#import "Spot.h"
#import "Preferences.h"



@implementation ImageCanvas

@synthesize thePath;
@synthesize thePoint;
@synthesize pathColor;
@synthesize scale;
@synthesize zoom;
@synthesize actualImage;
@synthesize actulImageURL;
@synthesize imageRep;
@synthesize centeringPoint;
@synthesize indexOfPointToMove;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSImage *) flipImage:(NSImage *)unflipped{
    NSAffineTransform *flipper = [NSAffineTransform transform];
    
    NSSize dimensions = unflipped.size;
    
    
    if (dimensions.height < 10) {
        NSLog(@"the image has dimensions zero: %@",actulImageURL);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:@"ImageSize thinks its zero"];
        [alert setInformativeText:@"this particular action passed a weird image.  Do you still crash after hitting 'OK'?"];
        [alert addButtonWithTitle:@"OK"];
        
        [alert runModal];
        
        
        return unflipped;
        
    }else{
    
    
        NSImage *aFrame = [unflipped copy];
        [aFrame lockFocus];
        [flipper scaleXBy:1.0 yBy:-1.0];
        [flipper set];
        [aFrame drawAtPoint:NSMakePoint(0,-dimensions.height)
                   fromRect:NSMakeRect(0,0, dimensions.width, dimensions.height)
                  operation:NSCompositeCopy fraction:1.0];
        [aFrame unlockFocus];
        return aFrame;
    }
    
}

-(NSInteger)NearestIndexToPoint:(NSPoint)fromPoint toPoints:(NSArray *)pointArray{
    float minDist = 1000;
    NSInteger indexOfNearest = -1;
    for (NSInteger i=0; i<pointArray.count; i++) {
        NSPoint eachPoint = [[pointArray objectAtIndex:i] pointValue];
        CGFloat distance = hypotf(fromPoint.x - eachPoint.x,fromPoint.y - eachPoint.y);
        if (distance < minDist) {
            indexOfNearest = i;
            minDist = distance;
        }
    }
    if (indexOfNearest <1) {
        indexOfNearest=1;
    }
    return indexOfNearest;
}

-(void)mouseDown:(NSEvent *)theEvent{
    NSPoint mouseRawPoint = [theEvent locationInWindow];
    NSPoint mousePoint = [self convertPoint: mouseRawPoint fromView: nil];
    
    
    NSArray *pointList = [[NSArray alloc] init];
    NSPoint pointObject[3];
    for (NSInteger i=0; i<[thePath elementCount]; i++) {
        NSBezierPathElement eachElement = [thePath elementAtIndex:i associatedPoints:pointObject];
        NSPoint eachPoint = pointObject[0];
        pointList = [pointList arrayByAddingObject:[NSValue valueWithPoint:eachPoint]];
    }
    indexOfPointToMove = [self NearestIndexToPoint:mousePoint toPoints:pointList];
    
    Document *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
    DocDelegate *myDelegate = [myDoc DocumentDelegate];
    [myDelegate.SpotControllerOutlet setSelectionIndex:indexOfPointToMove - 1];
    
    
}


-(void)mouseDragged:(NSEvent *)theEvent{
    NSPoint mouseRawPoint = [theEvent locationInWindow];
    NSPoint mousePoint = [self convertPoint: mouseRawPoint fromView: nil];
    Document *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
    DocDelegate *myDelegate = [myDoc DocumentDelegate];
    Preferences *myPrefs = [[myDelegate.PreferencesControllerOutlet arrangedObjects] objectAtIndex:0];
    
    if(myPrefs.isShowingImage){
    
        NSArray *spotArray = [myDelegate.SpotControllerOutlet arrangedObjects];
        [myDelegate.SpotControllerOutlet setSelectionIndex:indexOfPointToMove -1];
        Spot *initialSpot = [spotArray objectAtIndex:0];
        Spot *selectedSpot =[spotArray objectAtIndex:(indexOfPointToMove - 1)];
        
        
        
    //    NSPoint spotPoint = NSMakePoint((theX * zoom) + centerX, (theY  * zoom + centerY));
        NSRect theBounds = self.bounds;
        float centerX = theBounds.size.width / 2;
        float centerY = theBounds.size.height / 2;
        
        float initialX = [initialSpot.x floatValue];
        float initialY = [initialSpot.y floatValue];
        
        [selectedSpot setX:[NSNumber numberWithFloat:((mousePoint.x - centerX) / zoom) + initialX]];
        [selectedSpot setY:[NSNumber numberWithFloat:((mousePoint.y - centerY) / zoom) + initialY]];
        [myDelegate UpdateTrackBezierCanvas];

    }
}

-(void)mouseUp:(NSEvent *)theEvent{
    Document *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
    DocDelegate *myDelegate = [myDoc DocumentDelegate];
    [myDelegate UpdateTrackBezierCanvas];
    [myDelegate UpdateGraphs];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSDocumentController *myDocController = [NSDocumentController sharedDocumentController];
    Document *myDoc = [myDocController currentDocument];
    DocDelegate *myDelegate = [myDoc DocumentDelegate];
    Preferences *myPrefs = [[myDelegate.PreferencesControllerOutlet arrangedObjects] objectAtIndex:0];
    
    NSRect canvasEdges = self.bounds;
    CGFloat canvasWidth = canvasEdges.size.width;
    CGFloat canvasHeight = canvasEdges.size.height;
    
    
    if (actualImage != nil) {
        actualImage = [self flipImage:actualImage];
        float realX = actualImage.size.width;
        float realY = actualImage.size.height;
        float pixelX = [imageRep pixelsWide];
        float pixelY = [imageRep pixelsHigh];
        if (realX < 10) {
            NSLog(@"the image that didn't work is called %@",actulImageURL);
        }
        
        float fractionX = realX / pixelX;
        float fractionY = realY / pixelY;
        
        if ([myPrefs.isShowingImage floatValue] == 1) {
            
            NSRect croppedImageRect = NSMakeRect( (centeringPoint.x - (canvasWidth /zoom / 2)) * fractionX, (centeringPoint.y - (canvasHeight /zoom / 2)) * fractionY, canvasWidth / zoom * fractionX , canvasHeight / zoom * fractionY);
            
            
            
            
            
            //let's try and autoadjust the image?
  
            
                NSNumber *exposureValue = [NSNumber numberWithFloat:6.5];
                NSNumber *contrastValue = [NSNumber numberWithFloat:1.15];
                
                
                CIContext *context = [[CIContext alloc] init];
                CIImage *image = [CIImage imageWithContentsOfURL:actulImageURL];
            
            
            
                CIFilter *controlsFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
                [controlsFilter setValue:image forKey:kCIInputImageKey];
                [controlsFilter setValue:exposureValue forKey:@"inputEV"];
                CIImage *exposed = [controlsFilter valueForKey:@"outputImage"];
            
            
                CIFilter *contrastFilter = [CIFilter filterWithName:@"CIColorControls"];
                [contrastFilter setDefaults];
                [contrastFilter setValue:exposed forKey:@"inputImage"];
                [contrastFilter setValue:contrastValue forKey:@"inputContrast"];
                CIImage *outputImage = [contrastFilter valueForKey:@"outputImage"];

                
                
                CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
                [transform setValue:outputImage forKey:@"inputImage"];
                
                NSAffineTransform *affineTransform = [NSAffineTransform transform];
                [affineTransform translateXBy:0 yBy:outputImage.extent.size.width];
                [affineTransform scaleXBy:1 yBy:-1];
                [transform setValue:affineTransform forKey:@"inputTransform"];
             
                CIImage * result = [transform valueForKey:@"outputImage"];
                
                
                
                
                CGImageRef cgImages = [context createCGImage:result fromRect:[result extent]];
                NSImage *newImage = [[NSImage alloc] initWithCGImage:cgImages size:NSZeroSize];
                

                [newImage drawInRect:canvasEdges fromRect:croppedImageRect operation:NSCompositeCopy fraction:1.0 respectFlipped:NO hints:Nil];
                
//                [actualImage drawInRect:canvasEdges fromRect:croppedImageRect operation:NSCompositeCopy fraction:1.0 respectFlipped:NO hints:Nil];
        
        }
    }
    
    if (thePath.elementCount > 0) {
        
        if ([myPrefs.isShowingTrack integerValue] == 1) {
            [thePath setLineWidth:2.0]; /// Make it easy to see
            [[NSColor blueColor] set];
            NSColor *color = myPrefs.trackColor;
            if (color == nil) {
                color = [NSColor blueColor];
            }
            [color set];
            [thePath stroke];
        }
        
        
        NSRect theEdge = thePath.bounds;
        NSPoint xMed = NSMakePoint(theEdge.origin.x + theEdge.size.width + 3, theEdge.origin.y + (theEdge.size.height /2));
        NSPoint yMed = NSMakePoint((theEdge.origin.x + (theEdge.size.width /3 )), theEdge.origin.y - 20);
        
        
        if ([myPrefs.isShowingPoint integerValue] == 1) {
            NSInteger radius = [myPrefs.spotSize integerValue];
            NSRect rect = NSMakeRect(thePoint.x - radius, thePoint.y - radius, radius * 2, radius * 2);
            NSBezierPath* circlePath = [NSBezierPath bezierPath];
            [circlePath appendBezierPathWithOvalInRect: rect];
            [[NSColor redColor] set];
            [circlePath setLineWidth:2];
            [circlePath stroke];
        }
        
        
        [[NSColor blackColor] set];
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(NSMinX([thePath bounds]), NSMinY([thePath bounds]))];
        [line lineToPoint:NSMakePoint(NSMaxX([thePath bounds]), NSMinY([thePath bounds]))];
        [line lineToPoint:NSMakePoint(NSMaxX([thePath bounds]), NSMaxY([thePath bounds]))];
        [line setLineWidth:1];
        [line stroke];
        
        
        
        // [[NSColor blackColor] set];
        //NSFrameRect(theEdge);
        
        NSString *widthScale = [NSString stringWithFormat:@"%.0001f μm",(theEdge.size.width / zoom * scale)];
        NSString *heightScale = [NSString stringWithFormat:@"%.0001f μm",(theEdge.size.height / zoom * scale)];
        
        
        [widthScale drawAtPoint:yMed withAttributes:nil];
        [heightScale drawAtPoint:xMed withAttributes:nil];
    [self setNeedsDisplay:YES];
        
    }
}


- (NSImage *) autoAdjustImageWithURL:(NSURL *)inputImageURL{
    
    
    CIContext *context = [[CIContext alloc] init];
    CIImage *image = [CIImage imageWithContentsOfURL:inputImageURL];
    
    NSArray *autoFilters = [image autoAdjustmentFilters];
    CIFilter *highlightShadowAdjustFilter = [autoFilters objectAtIndex:1];
    [highlightShadowAdjustFilter setValue:image forKey:kCIInputImageKey];
    
    CIImage *results = [highlightShadowAdjustFilter valueForKey:kCIOutputImageKey];
    CGImageRef cgImages = [context createCGImage:results fromRect:[results extent]];
    NSImage *newImage = [[NSImage alloc] initWithCGImage:cgImages size:NSZeroSize];
    
    
    return newImage;
}


@end


@implementation LineGraph

@synthesize xArray;
@synthesize yArray;
@synthesize redXYFinal;
@synthesize redXYInitial;
@synthesize redWidth;
@synthesize timeSig;
@synthesize hasRed;
@synthesize hasDotted;
@synthesize hasTimeSig;
@synthesize hasAlphaCurve;
@synthesize alphas;
@synthesize xMax;
@synthesize yMax;


- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) drawRect:(NSRect)dirtyRect{
    
    NSRect canvasEdges = self.bounds;

    NSInteger margin = 20;
    float xPixels = canvasEdges.size.width - 1;
    float yPixels = canvasEdges.size.height - (2 * margin);
    NSPoint zeroPoint = NSMakePoint(1, margin);
    [[NSColor blackColor] set];
    
    NSBezierPath *xAxis = [NSBezierPath bezierPath];
    [xAxis moveToPoint:zeroPoint];
    [xAxis lineToPoint:NSMakePoint(self.bounds.size.width, margin)];
    [xAxis setLineWidth:1];
    [xAxis stroke];
    
    NSBezierPath *yAxis = [NSBezierPath bezierPath];
    [yAxis moveToPoint:zeroPoint];
    [yAxis lineToPoint:NSMakePoint(1, yPixels + margin)];
    [yAxis setLineWidth:1];
    [yAxis stroke];
    
        [[NSColor blackColor] set];
    
    if (xArray.count > 0) {

        xMax = [[xArray valueForKeyPath:@"@max.floatValue"] floatValue];
        yMax = [[yArray valueForKeyPath:@"@max.floatValue"] floatValue];
        if (yMax != 0) {
           
        
            
            NSBezierPath *xyPath = [NSBezierPath bezierPath];
            [xyPath moveToPoint:zeroPoint];
            NSNumber *numberOfValues = [NSNumber numberWithInteger: [yArray count]];
            float fNumberOfValues = [numberOfValues floatValue];
            for (NSInteger i = 0; i< ([numberOfValues integerValue]); i++) {
                NSNumber *theY = [yArray objectAtIndex:i];
                float iFloat = [[NSNumber numberWithInteger:i] floatValue];
                float fraction = iFloat / fNumberOfValues;
                
                float pixelX =  ((fraction) * xPixels) + 1;
                float pixelY =  (([theY floatValue] / yMax ) * yPixels) + margin;
                
                
                NSPoint xyPoint = NSMakePoint(pixelX, pixelY);
                [xyPath lineToPoint:xyPoint];
            }
            [xyPath setLineWidth:1];
            [[NSColor grayColor] set];
            [xyPath stroke];
        
            if (hasTimeSig) {
                NSBezierPath *redCurve = [NSBezierPath bezierPath];
                
                
                NSInteger redlineWidth = 1;
                [[NSColor redColor] set];
                NSPoint initialTimeSigPoint = NSMakePoint((timeSig.x -1) / xArray.count * xPixels + 1, 0 + margin);
                NSPoint finalTimeSigPoint = NSMakePoint((timeSig.x - 1) / xArray.count * xPixels + 1, yPixels + margin);
                
                if ([redWidth integerValue]> 1) {
                    
                    NSInteger lineNumber = [redWidth integerValue];
                    float unit =  xPixels / xArray.count;
                    float offset = lineNumber / 2;
                    
                    float newX = (((timeSig.x - 1) + offset) / xArray.count * xPixels + 1);
                    initialTimeSigPoint = NSMakePoint(newX, 0 + margin);
                    finalTimeSigPoint = NSMakePoint(newX, yPixels + margin);
                    
                    redlineWidth = (lineNumber * unit);
                    NSColor *redOpacityColor = [NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:.2f];
                    [redOpacityColor set];
                }
                
                [redCurve moveToPoint:initialTimeSigPoint];
                [redCurve lineToPoint:finalTimeSigPoint];
                [redCurve setLineWidth:redlineWidth];
                [redCurve stroke];
                
            }
            
            
        
            
            if (hasRed) {
                
            
                NSBezierPath *redCurve = [NSBezierPath bezierPath];
                NSPoint initialRedPoint = NSMakePoint(redXYInitial.x / xMax * xPixels + 1, redXYInitial.y / yMax * yPixels + margin);
                NSPoint finalRedPoint = NSMakePoint(redXYFinal.x / xMax * xPixels + 1, redXYFinal.y / yMax *yPixels + margin);
                [redCurve moveToPoint:initialRedPoint];
                [redCurve lineToPoint:finalRedPoint];
                [[NSColor redColor] set];
                [redCurve setLineWidth:1];
                [redCurve stroke];
            
            
                if (hasDotted) {
                    
                    NSBezierPath *redDotted = [NSBezierPath bezierPath];
                    [redDotted moveToPoint:finalRedPoint];
                    float scaledX = (finalRedPoint.x - initialRedPoint.x);
                    float scaledY = (finalRedPoint.y - initialRedPoint.y);
                    
                    NSPoint finalRedDotPoint = NSMakePoint(1 * xPixels + 1, (xPixels - finalRedPoint.x) / scaledX * scaledY + finalRedPoint.y );
                    [redDotted lineToPoint:finalRedDotPoint];
                    [[NSColor orangeColor] set];
                    [redDotted setLineWidth:1];
                    CGFloat dashPattern[] = {6,6}; //dash pattern here
                    [redDotted setLineDash:dashPattern count:2 phase:2];
                    [redDotted stroke];
                    
                }
            }
            
            if (hasAlphaCurve) {
                NSBezierPath *blueCurve = [NSBezierPath bezierPath];

                [blueCurve moveToPoint:zeroPoint];
                NSNumber *numberOfValues = [NSNumber numberWithInteger: [alphas count]];
                float fNumberOfValues = [numberOfValues floatValue];
                for (NSInteger i = 0; i< ([numberOfValues integerValue]); i++) {
                    NSNumber *theY = [alphas objectAtIndex:i];
                    float iFloat = [[NSNumber numberWithInteger:i] floatValue];

                    float fraction = iFloat / fNumberOfValues;
                    
                    float pixelX =  ((fraction) * xPixels) + 1;
                    float pixelY =  (([theY floatValue] / yMax ) * yPixels) + margin;
                    
                    
                    NSPoint xyPoint = NSMakePoint(pixelX, pixelY);
                    [blueCurve lineToPoint:xyPoint];
                }
                
                [[NSColor blueColor] set];
                [blueCurve setLineWidth:1];
                [blueCurve stroke];
                
                
            }
        }

    }
}

@end



@implementation Histogram

@synthesize ptArray;
@synthesize bins;


- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) drawRect:(NSRect)dirtyRect{
    NSRect canvasEdges = self.bounds;
    NSInteger margin = 10;
    float xPixels = canvasEdges.size.width - 1;
    float yPixels = canvasEdges.size.height - (2 * margin);
    
    
    
    float xMin = [[ptArray valueForKeyPath:@"@min.self"] floatValue];
    float xMax = [[ptArray valueForKeyPath:@"@max.self"] floatValue];
    float binWidth = (xMax - xMin) / bins;
    float xWidth = self.bounds.size.width;
    float xBinWidth = xWidth / bins;

    
    NSPoint zeroPoint = NSMakePoint(1, margin);
    [[NSColor blackColor] set];
    
    NSBezierPath *xAxis = [NSBezierPath bezierPath];
    [xAxis moveToPoint:zeroPoint];
    [xAxis lineToPoint:NSMakePoint(xWidth, margin)];
    [xAxis setLineWidth:2];
    [xAxis stroke];
    
    NSBezierPath *yAxis = [NSBezierPath bezierPath];
    [yAxis moveToPoint:zeroPoint];
    [yAxis lineToPoint:NSMakePoint(1, yPixels)];
    [yAxis setLineWidth:2];
    [yAxis stroke];

    
    
    NSArray *barArray = [[NSArray alloc] init];
    
    
    float yBinWidth = 10;
    for (int i=0; i < bins; i++) {
        
        float amount = 5; //input the histogram value as amount//
        
        
        
        float xLeft = i * xBinWidth;
        float xRight = xLeft + xBinWidth;
        float yFloor = margin;
        float yHeight = margin + (amount * yBinWidth);
    
        
        NSBezierPath *box = [NSBezierPath bezierPath];
        
        
        [box setLineWidth:2];
        [box stroke];
        
    }
    
    
    
    
}



@end




@implementation FrameCanvas

@synthesize spots;
@synthesize imageRep;
@synthesize actualImage;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
-(void)drawRect:(NSRect)dirtyRect{

    if (actualImage != nil) {
        Document *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
        DocDelegate *myDelegate = [myDoc DocumentDelegate];
        
        Frame *myFrame = [[myDelegate.FrameControllerOutlet selectedObjects] objectAtIndex:0];
        
        actualImage = [self flipImage:actualImage];
        NSData *tifData = [actualImage TIFFRepresentation];
        
        NSImage *thisImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:myFrame.filename]];
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithContentsOfURL:[NSURL URLWithString:myFrame.filename]];
        float changeBy = [myDelegate.WhitePointSliderOutlet floatValue];
        CGFloat cFloat = changeBy;
        CIVector *changeVector = [CIVector vectorWithValues:&cFloat count:4];
        CIColor *newWhite = [CIColor colorWithRed:changeBy green:changeBy blue:changeBy];
        
        CIImage* ciImage = [[CIImage alloc] initWithData:[actualImage TIFFRepresentation]];

        
        
        
        CIFilter* inverter = [CIFilter filterWithName:@"CIColorInvert"];
        [inverter setDefaults];
        [inverter setValue:ciImage forKey:@"inputImage"];
        CIImage* inverterOutput = [inverter valueForKey:@"outputImage"];

        
        
        CIFilter* contraster = [CIFilter filterWithName:@"CIWhitePointAdjust"];
        [contraster setDefaults];
        [contraster setValue:inverterOutput forKey:@"inputImage"]; ////inverterOutput
        [contraster setValue:newWhite forKey:@"inputColor"];
        CIImage *output = [contraster valueForKey:@"outputImage"];
        
        
        [output drawAtPoint:NSZeroPoint fromRect:NSRectFromCGRect([output extent]) operation:NSCompositeSourceOver fraction:1.0];
        
        //[inverterOutput drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1];
        
        
        
        ///[actualImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0 respectFlipped:NO hints:Nil];
        
        
        [[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.9] set];
        
        for (NSBezierPath *eachCircle in spots) {
            [eachCircle setLineWidth:1];
            [eachCircle stroke];
        }
            [self setNeedsDisplay:YES];

    }
}
                                                
                                                
- (NSImage *) flipImage:(NSImage *)unflipped{
    NSAffineTransform *flipper = [NSAffineTransform transform];
    
    NSSize dimensions = actualImage.size;
    
    if (dimensions.height < 10) {
                NSLog(@"Error coming from FrameCanvas");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:@"ImageSize thinks its zero"];
        [alert setInformativeText:@"this particular action passed a weird image.  Do you still crash after hitting 'OK'?"];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];

        
        return unflipped;
        
    }else{
        NSImage *aFrame = [actualImage copy];
        [aFrame lockFocus];
        [flipper scaleXBy:1.0 yBy:-1.0];
        [flipper set];
        [aFrame drawAtPoint:NSMakePoint(0,-dimensions.height)
                   fromRect:NSMakeRect(0,0, dimensions.width, dimensions.height)
                  operation:NSCompositeCopy fraction:1.0];
        [aFrame unlockFocus];
        return aFrame;
    }
    
}
                                                


                                                
                                                
                                                
@end




@implementation toNumber
- (id)transformedValue:(id)value{
    NSNumber *output = [NSNumber numberWithInteger:[value integerValue]];
    return output;
}
@end

@implementation countMinusOne
- (id)transformedValue:(id)value{
    NSNumber *output = [NSNumber numberWithInteger:([value integerValue] - 1)];
    return output;
}
@end
@implementation boolColor
- (id)transformedValue:(id)value{
//    if([value isTrue]){return [NSImage imageNamed:NSImageNameStatusAvailable];}
//    else{return [NSImage imageNamed:NSImageNameStatusUnavailable];};
    NSInteger input = [value integerValue];
    if (input == 1) {
        return [NSImage imageNamed:NSImageNameStatusAvailable];
    }else{return [NSImage imageNamed:NSImageNameStatusUnavailable];}
}
@end


@implementation AdjustedImage

- (id)transformedValue:(id)value{
    DocDelegate *delegate = [[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate];
    NSNumber *contrastValue =[NSNumber numberWithFloat:[delegate.ContrastSliderOutlet floatValue]];
    NSNumber *exposureValue = [NSNumber numberWithFloat:[delegate.ExposureSliderOutlet floatValue]];
    
    CIContext *context = [[CIContext alloc] init];
    NSURL *myImageURL = [NSURL URLWithString:value];
    CIImage *image = [CIImage imageWithContentsOfURL:myImageURL];
    
    
    CIFilter *controlsFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [controlsFilter setValue:image forKey:kCIInputImageKey];
    [controlsFilter setValue:exposureValue forKey:@"inputEV"];
    CIImage *exposed = [controlsFilter valueForKey:@"outputImage"];
    
    CIFilter *contrastFilter = [CIFilter filterWithName:@"CIColorControls"];
    [contrastFilter setDefaults];
    [contrastFilter setValue:exposed forKey:@"inputImage"];
    [contrastFilter setValue:contrastValue forKey:@"inputContrast"];
    CIImage *outputImage = [contrastFilter valueForKey:@"outputImage"];
    
    
   // NSArray *autoFilters = [image autoAdjustmentFilters];
  //  CIFilter *highlightShadowAdjustFilter = [autoFilters objectAtIndex:2];
    
   // CIFilter *colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
   // [colorControlsFilter setDefaults];
   // [colorControlsFilter setValue:image forKey:@"inputImage"];
    //[colorControlsFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputSaturation"];
    //[colorControlsFilter setValue:[NSNumber numberWithFloat:0.2] forKey:@"inputBrightness"];
    //[colorControlsFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputContrast"];
    
    //CIImage *outputImage = [colorControlsFilter valueForKey:@"outputImage"];
    
 //   DocDelegate *delegate = [[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate];
    
 //   if ([delegate.UseContrastSliderOutlet integerValue]) {
  //      NSNumber *contrastValue =[NSNumber numberWithFloat:[delegate.ContrastSliderOutlet floatValue]];
        
  //      CIFilter *exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
  //      [exposureFilter setDefaults];
  //      [exposureFilter setValue:contrastValue forKey:@"inputEV"];
  //      [exposureFilter setValue:image forKey:@"inputImage"];

   //     CIImage *outputImage = [exposureFilter valueForKey:@"outputImage"];
        
  //  }
    
    
    
       // [highlightShadowAdjustFilter setValue:image forKey:kCIInputImageKey];
        
       // CIImage *results = [highlightShadowAdjustFilter valueForKey:kCIOutputImageKey];
        CGImageRef cgImages = [context createCGImage:outputImage fromRect:[outputImage extent]];
        NSImage *newImage = [[NSImage alloc] initWithCGImage:cgImages size:NSZeroSize];

    
    return newImage;
}

@end