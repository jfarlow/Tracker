//
//  MathArray.m
//  trax
//
//  Created by Justin Farlow on 2/20/13.
//  Copyright (c) 2013 biotecture. All rights reserved.
//

#import "AppDelegate.h"
#import "DocDelegate.h"
#import "MathArray.h"
#import "Experiment.h"
#import "Spot.h"
#import "Track.h"

@implementation NSArray(MathArray)

- (float)msdWithDeltaT:(int)deltaT withLengthScale:(float)lengthScale{
    NSArray *xArray = [self valueForKey:@"x"];
    NSArray *yArray = [self valueForKey:@"y"];
    
    NSArray *distanceArray = [[NSArray alloc] init];
    
    if (self.count>deltaT) {
        
        for (int t=0; t< (self.count - deltaT); t++) {
            float x1 = [[xArray objectAtIndex:t] floatValue] * lengthScale;
            float y1 = [[yArray objectAtIndex:t] floatValue] * lengthScale;
            
            float x2 = [[xArray objectAtIndex:(t+deltaT)] floatValue] * lengthScale;
            float y2 = [[yArray objectAtIndex:(t+deltaT)] floatValue] * lengthScale;
            
            float d2 = powf((x2 - x1), 2.0) + powf((y2-y1), 2.0);
            
            NSNumber *numD2 = [NSNumber numberWithFloat:d2];
            distanceArray = [distanceArray arrayByAddingObject:numD2];
        }
    }else{
        //dT is greater than array distance
        return 0;
    }
    
    float sum = 0.0;
    for (NSNumber *each in distanceArray) {
        sum = sum + each.floatValue;
    }
    float rawmsd = sum /distanceArray.count;
    float msd = rawmsd;
    return msd;
}



@end




@implementation RegressionResult

@synthesize slope = _slope;
@synthesize intercept = _intercept;
@synthesize correlation = _correlation;

@end


@interface LinearRegression()
@property (nonatomic) float slope;
@property (nonatomic) float intercept;
@property (nonatomic) float correlation;
@property (nonatomic) float sumY;
@property (nonatomic) float sumX;
@property (nonatomic) float sumXY;
@property (nonatomic) float sumX2;
@property (nonatomic) float sumY2;

@end

@implementation LinearRegression

@synthesize slope = _slope;
@synthesize intercept = _intercept;
@synthesize correlation = _correlation;
@synthesize sumY = _sumY;
@synthesize sumX = _sumX;
@synthesize sumXY = _sumXY;
@synthesize sumX2 = _sumX2;
@synthesize sumY2 = _sumY2;




- (RegressionResult *)calculateRegressionwithXs:(NSArray *)xArray withYs:(NSArray *)yArray{
    
    // theArray should be an array of DataItem objects that each contain
    // two float numbers ( the x and y value of the data)
    // if you created the original array as a NSMutableArray so you could add
    // objects, you will probably want to make a copy like
    // NSArray *theArray = [mutableArray copy]; and then call the linearRegression object like
    // [instanceOfLinearRegressionData calculateRegression:theArray];
    RegressionResult *result = [[RegressionResult alloc] init];
    
    if(xArray.count == yArray.count){
        NSInteger theNumber = xArray.count;
        self.sumY = 0.0;
        self.sumX = 0.0;
        self.sumXY = 0.0;
        self.sumX2 = 0.0;
        self.sumY2 = 0.0;
        
        for (int i=0; i<theNumber; i++) {
            float xValue = [[xArray objectAtIndex:i] floatValue];
            float yValue = [[yArray objectAtIndex:i] floatValue];
            self.sumX = _sumX + xValue;
            self.sumY = _sumY + yValue;
            self.sumXY = _sumXY + (xValue * yValue);
            self.sumX2 = _sumX2 + (xValue * xValue);
            self.sumY2 = _sumY2 + (yValue * yValue);
        }
        result.slope = ((theNumber * self.sumXY) - self.sumX * self.sumY) / ((theNumber * self.sumX2) - (self.sumX * self.sumX));
        result.intercept = (self.sumY - (result.slope * self.sumX)) / theNumber;
        
        result.correlation = ((theNumber * self.sumXY) - (self.sumX * self.sumY)) / (sqrt(theNumber * self.sumX2 - (self.sumX * self.sumX)) * sqrt(theNumber * self.sumY2 - (self.sumY * self.sumY)));
        return result;
    }else{
        return nil;
    }
}

@end






@implementation realizeTimeUnits

- (id)transformedValue:(id)value{
    DocDelegate *myDoc = [[NSDocumentController sharedDocumentController] delegate];
    NSInteger UseUnits = [myDoc.UnitsOfChoiceOutlet integerValue];
    NSArray *experiments  = [myDoc.TrackControllerOutlet selectedObjects];
    if (experiments.count > 0 && UseUnits > 0) {
        Experiment *myExperiment = [experiments objectAtIndex:0];
        float converted = ([value floatValue] * [myExperiment.timeScale floatValue]);
        return [NSNumber numberWithFloat:converted];
    }
    return value;
}
- (id)reverseTransformedValue:(id)value{
    DocDelegate *myDoc = [[NSDocumentController sharedDocumentController] delegate];
    NSInteger UseUnits = [myDoc.UnitsOfChoiceOutlet integerValue];
    NSArray *experiments  = [myDoc.TrackControllerOutlet selectedObjects];
    if (experiments.count > 0 && UseUnits > 0) {
        Experiment *myExperiment = [experiments objectAtIndex:0];
        float converted = ([value floatValue] / [myExperiment.timeScale floatValue]);
        return [NSNumber numberWithFloat:converted];
    }
    return value;
}

@end

@implementation realizeLengthUnits

- (id)transformedValue:(id)value{
    DocDelegate *myDoc = [[NSDocumentController sharedDocumentController] delegate];
    NSInteger UseUnits = [myDoc.UnitsOfChoiceOutlet integerValue];
    NSArray *experiments  = [myDoc.TrackControllerOutlet selectedObjects];
    if (experiments.count > 0 && UseUnits > 0) {
        Experiment *myExperiment = [experiments objectAtIndex:0];
        float converted = ([value floatValue] * [myExperiment.lengthScale floatValue]);
        return [NSNumber numberWithFloat:converted];
    }
    return value;
}

- (id)reverseTransformedValue:(id)value{
    DocDelegate *myDoc = [[NSDocumentController sharedDocumentController] delegate];
    NSInteger UseUnits = [myDoc.UnitsOfChoiceOutlet integerValue];
    NSArray *experiments  = [myDoc.TrackControllerOutlet selectedObjects];
    if (experiments.count > 0 && UseUnits > 0) {
        Experiment *myExperiment = [experiments objectAtIndex:0];
        float converted = ([value floatValue] / [myExperiment.lengthScale floatValue]);
        return [NSNumber numberWithFloat:converted];
    }
    return value;
}

@end
