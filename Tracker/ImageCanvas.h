//
//  ImageCanvas.h
//  Tracker
//
//  Created by Justin Farlow on 4/8/13.
//  Copyright (c) 2013 UCSF. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ImageCanvas : NSView

@property (nonatomic) NSBezierPath *thePath;
@property (nonatomic) NSPoint thePoint;
@property (nonatomic) NSColor *pathColor;
@property (nonatomic) float scale;
@property (nonatomic) float zoom;
@property (nonatomic) NSImage *actualImage;
@property (nonatomic) NSURL *actulImageURL;
@property (nonatomic) NSBitmapImageRep *imageRep;
@property (nonatomic) NSPoint centeringPoint;
@property (nonatomic) NSInteger indexOfPointToMove;

- (id)initWithFrame:(NSRect)frame;
-(NSInteger)NearestIndexToPoint:(NSPoint)fromPoint toPoints:(NSArray *)pointArray;
- (void)mouseDragged:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;
-(void)mouseUp:(NSEvent *)theEvent;
- (void) drawRect:(NSRect)dirtyRect;
- (NSImage *) flipImage:(NSImage *)unflipped;
- (NSImage *) autoAdjustImageWithURL:(NSURL *)inputImageURL;
@end


@interface LineGraph : NSView

@property (nonatomic) NSArray *xArray;
@property (nonatomic) NSArray *yArray;
@property (nonatomic) NSPoint redXYFinal;
@property (nonatomic) NSPoint redXYInitial;
@property (nonatomic) NSNumber *redWidth;
@property (nonatomic) NSPoint timeSig;
@property (nonatomic) BOOL hasRed;
@property (nonatomic) BOOL hasDotted;
@property (nonatomic) BOOL hasTimeSig;
@property (nonatomic) BOOL hasAlphaCurve;
@property (nonatomic) NSArray *alphas;
@property (nonatomic) float xMax;
@property (nonatomic) float yMax;


- (id)initWithFrame:(NSRect)frame;
- (void) drawRect:(NSRect)dirtyRect;

@end


@interface Histogram : NSView

@property (nonatomic) NSArray *ptArray;
@property (nonatomic) NSInteger bins;

- (id)initWithFrame:(NSRect)frame;
- (void) drawRect:(NSRect)dirtyRect;

@end


@interface FrameCanvas : NSView
@property (nonatomic) NSArray *spots;
@property (nonatomic) NSBitmapImageRep *imageRep;
@property (nonatomic) NSImage *actualImage;


- (NSImage *) flipImage:(NSImage *)unflipped;
- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)dirtyRect;

@end






@interface toNumber : NSValueTransformer{
}
@end
@interface countMinusOne : NSValueTransformer{
}
@end
@interface boolColor : NSValueTransformer{
}
@end

@interface AdjustedImage : NSValueTransformer{
}
@end

