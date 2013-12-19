//
//  AcceleratableLayer.h
//  CalibrationDemo
//
//  Created by Lynn Pye Jr. on 5/22/11.
//  Copyright 2011 Lynn Pye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AcceleratableLayer : CCLayer {
    
    float biasX;
    float biasY;
    
    float lastAccelX;
    float lastAccelY;
    
    CGPoint playerVelocity;
    
    BOOL adjustForBias;
}

@property (readwrite) float biasX;
@property (readwrite) float biasY;
@property (readwrite) BOOL adjustForBias;
@property (readwrite) float lastAccelX;
@property (readwrite) float lastAccelY;

-(CGPoint) adjustPositionByVelocity:(CGPoint)oldpos;
-(CGRect) allowableMovementArea;

+(float) lastAccelX;
+(float) lastAccelY;
+(float) biasX;
+(float) biasY;
+(void) setBiasX:(float)x;
+(void) setBiasY:(float)y;

@end

