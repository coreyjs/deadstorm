//
//  AcceleratableLayer.m
//  CalibrationDemo
//
//  Created by Lynn Pye Jr. on 5/22/11.
//  Copyright 2011 Lynn Pye. All rights reserved.
//

/*
 * This code is a modified version of the GameScene.m code in the
 * DoodleDrop example provided by Steffen Itterheim in his book
 * "Learn iPhone and iPad Cocos2D Game Development". I've altered the
 * code for modularity and reuse. It could be taken further. It
 * was originally adapted for use in a game I had written and had
 * to be further tweaked to pull it out for this demo. Even though 
 * the original code Steffen released retained a similar header as
 * above, which is the standard boilerplate automatically added
 * to any new files you create in Xcode, he had indicated that the
 * sample code could be reused. I extend my own permission in the
 * same way for any of my alterations. I hope you find it useful.
 */

#import "AcceleratableLayer.h"

// You can alter this to prevent someone from calibrating for too much tilt
#define MAX_ACCEL_BIAS (0.5f)

#pragma mark AcceleratableLayer
@implementation AcceleratableLayer

@synthesize biasX, biasY, adjustForBias, lastAccelX, lastAccelY;

static NSString* NSD_BIASX = @"biasX";
static NSString* NSD_BIASY = @"biasY";

+(float) biasX
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:NSD_BIASX];
}

+(float) biasY
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:NSD_BIASY];
}

+(void) setBiasX:(float)x
{
    [[NSUserDefaults standardUserDefaults] setFloat:x forKey:NSD_BIASX];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void) setBiasY:(float)y
{
    [[NSUserDefaults standardUserDefaults] setFloat:y forKey:NSD_BIASY];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id) init
{
    if ((self = [super init]))
    {   
        biasX = [AcceleratableLayer biasX];
        biasY = [AcceleratableLayer biasY];
        
        CCLOG(@"&&&&&&&&&&&&&&&&&& BIAS X: %f BIAS Y: %f", biasX, biasY);
        
        self.adjustForBias = YES;
    }
    return self;
}

// We will require a subclass
-(CGRect) allowableMovementArea
{
    [NSException exceptionWithName:@"MethodNotOverridden" reason:@"Must override this method" userInfo:nil];
    return CGRectZero;
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // used for calibration
    lastAccelX = acceleration.x;
    lastAccelY = acceleration.y;
    
    lastAccelX = fmaxf(fminf(lastAccelX,MAX_ACCEL_BIAS),-MAX_ACCEL_BIAS);
    lastAccelY = fmaxf(fminf(lastAccelY,MAX_ACCEL_BIAS),-MAX_ACCEL_BIAS);
    
	// These three values control how the player is moved. I call such values "design parameters" as they 
	// need to be tweaked a lot and are critical for the game to "feel right".
	// Sometimes, like in the case with deceleration and sensitivity, such values can affect one another.
	// For example if you increase deceleration, the velocity will reach maxSpeed faster while the effect
	// of sensitivity is reduced.
	
	// this controls how quickly the velocity decelerates (lower = quicker to change direction)
	float deceleration = 0.4f;
	// this determines how sensitive the accelerometer reacts (higher = more sensitive)
	float sensitivity = 6.0f;
	// how fast the velocity can be at most
	float maxVelocity = 10.0f;
    
	// adjust velocity based on current accelerometer acceleration (adjusting for bias)
    if (adjustForBias)
    {
        playerVelocity.x = playerVelocity.x * deceleration + (acceleration.x-biasX) * sensitivity;
        playerVelocity.y = playerVelocity.y * deceleration + (acceleration.y-biasY) * sensitivity;
    }
    else
    {
        playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * sensitivity;
        playerVelocity.y = playerVelocity.y * deceleration + acceleration.y * sensitivity;
    }
    
    // we must limit the maximum velocity of the player sprite, in both directions (positive & negative values)
    playerVelocity.x = fmaxf(fminf(playerVelocity.x,maxVelocity),-maxVelocity);
    playerVelocity.y = fmaxf(fminf(playerVelocity.y,maxVelocity),-maxVelocity);
}



-(CGPoint) adjustPositionByVelocity:(CGPoint)oldpos
{
    CGPoint pos = oldpos;
	pos.x += playerVelocity.x;
    pos.y += playerVelocity.y;
	
	// Alternatively you could re-write the above 3 lines as follows. I find the above more readable however.
	// player.position = CGPointMake(player.position.x + playerVelocity.x, player.position.y);
	
	// The seemingly obvious alternative won't work in Objective-C! It'll give you the following error.
	// ERROR: lvalue required as left operand of assignment
	// player.position.x += playerVelocity.x;
	
	// The Player should also be stopped from going outside the allowed area
    CGRect allowedRect = [self allowableMovementArea];
    
	// the left/right border check is performed against half the player image's size so that the sides of the actual
	// sprite are blocked from going outside the screen because the player sprite's position is at the center of the image
	if (pos.x < allowedRect.origin.x)
	{
		pos.x = allowedRect.origin.x;
        
		// also set velocity to zero because the player is still accelerating towards the border
		playerVelocity.x = 0;
	}
	else if (pos.x > (allowedRect.origin.x + allowedRect.size.width))
	{
		pos.x = allowedRect.origin.x + allowedRect.size.width;
        
		// also set velocity to zero because the player is still accelerating towards the border
		playerVelocity.x = 0;
	}
    
    if (pos.y < allowedRect.origin.y)
    {
        pos.y = allowedRect.origin.y;
        
        playerVelocity.y = 0;
    }
    else if (pos.y > (allowedRect.origin.y + allowedRect.size.height))
    {
        pos.y = allowedRect.origin.y + allowedRect.size.height;
        
        playerVelocity.y = 0;
    }
    return pos;
}

@end
