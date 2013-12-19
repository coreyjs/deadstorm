//
//  Bullet.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Bullet.h"
#import "GameScene.h"

@interface Bullet (PrivateMethods)
-(id) initWithBulletImage;
@end


@implementation Bullet

@synthesize velocity;
@synthesize isPlayerBullet;

+(id) bullet
{
	return [[self alloc] initWithBulletImage] ;
}

-(id) initWithBulletImage
{
	// Uses the Texture Atlas now.
	if ((self = [super initWithSpriteFrameName:@"bullet_3.png"]))
	{
        //CCLOG(@"bulletInit");
        
        winSize = [[CCDirector sharedDirector] winSize];
	}
    
    
	
	return self;
}


// Re-Uses the bullet Corey's
-(void) shootBulletAt:(CGPoint)startPosition velocity:(CGPoint)vel frameName:(NSString*)frameName isPlayerBullet:(bool)playerBullet
{
	self.velocity = vel;
	self.position = startPosition;
	[self setActiveStatus:YES];
	self.isPlayerBullet = playerBullet;

	// change the bullet's texture by setting a different SpriteFrame to be displayed
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
	[self setDisplayFrame:frame];
	
	[self scheduleUpdate];
	
	//CCRotateBy* rotate = [CCRotateBy actionWithDuration:1 angle:-360];
	//CCRepeatForever* repeat = [CCRepeatForever actionWithAction:rotate];
	//[self runAction:repeat];
}



-(void) setActiveStatus:(BOOL)activeStatus{
    
    self.visible = activeStatus;
    _active = activeStatus;
    if(activeStatus){
        //[self scheduleUpdate];
    }else{
        [self unscheduleUpdate];
        [self stopAllActions];
    }
}

-(void) update:(ccTime)delta{
    
    //TODO: Unschedule updates for inactive bullets??
    
    self.position = ccpAdd(self.position, velocity);
    
    // When the bullet leaves the screen, make it invisible

//    
    if(_active){
        if(self.position.x > winSize.width){
            [self setActiveStatus:NO];
            [self stopAllActions];
            [self unscheduleAllSelectors];
        }
        else if(self.position.x < 0){
            [self setActiveStatus:NO];
            [self stopAllActions];
            [self unscheduleAllSelectors];
        }
        else if(self.position.y > winSize.height){
            [self setActiveStatus:NO];
            [self stopAllActions];
            [self unscheduleAllSelectors];
        }
        else if(self.position.y < 0){
            [self setActiveStatus:NO];
            [self stopAllActions];
            [self unscheduleAllSelectors];
        }
    
    }
    
}

@end











