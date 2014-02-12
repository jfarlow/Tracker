//
//  MathArray.h
//  trax
//
//  Created by Justin Farlow on 2/20/13.
//  Copyright (c) 2013 biotecture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spot.h"
#import "Track.h"

@interface  NSArray (MathArray)

- (float)msdWithDeltaT:(int)deltaT withLengthScale:(float)lengthScale;

@end




@interface RegressionResult : NSObject

@property (nonatomic) float slope;
@property (nonatomic) float intercept;
@property (nonatomic) float correlation;

@end

@interface LinearRegression : NSObject

- (RegressionResult *)calculateRegressionwithXs:(NSArray *)xArray withYs:(NSArray *)yArray;

@end

@interface realizeTimeUnits : NSValueTransformer{
}
@end

@interface realizeLengthUnits : NSValueTransformer{
}
@end