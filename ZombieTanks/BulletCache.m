//
//  BulletCache.m
//  ShootEmUp
//
//  Created by Corey Schaf - Blaqk Sheep Studios
//  Copyright Corey Schaf - Blaqk Sheep Studios. All rights reserved.
//

#import "BulletCache.h"
#import "Bullet.h"
#import "EnemyEntity.h"
#import "Player.h"
#import "GameScene.h"


#define kTimeForFlameBoundingSprite .5

@interface BulletCache (PrivateMethods)

-(bool) isBulletCollidingWithRect:(CGRect)rect usePlayerBullets:(bool)usePlayerBullets;
-(BOOL) isBulletCollidingWithRect:(CGRect)rect usePlayerBullets:(bool)usePlayerBullets gunModiferType:(GunModifiers)gunType;

@end



@implementation BulletCache

#define kDoubleBulletAmount 2
#define kTripleBulletAmount 3

@synthesize regularBullets = _regularBullets;
@synthesize flameThrowerSystem = _flameThrowerSystem;
@synthesize flameThrowerBoundingSprite = _flameThrowerBoundingSprite;
@synthesize flameBoundingActive = m_bFlameBoundingSpriteIsActive;
@synthesize nukeBoundingSprite = _nukeBoundingSprite;
@synthesize nukeBoundingActive = m_bNukeBoundingSpriteIsActive;


-(id) init
{
	if ((self = [super init]))
	{
        CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame *bulletFrameRegular = [cache spriteFrameByName:@"yellow_bullet.png"];
        _regularBulletBatch = [CCSpriteBatchNode batchNodeWithTexture:bulletFrameRegular.texture];
         [self addChild:_regularBulletBatch];
        
        nextInactiveRegularBullet = 0;
        _regularBullets = [[CCArray alloc] initWithCapacity:200];
        for(int i = 0; i < 200; i++){
            
            Bullet* bullet = [Bullet bullet];
            [bullet setActiveStatus:NO];
           // [_regularBullets addObject:bullet];
            [_regularBulletBatch addChild:bullet];
        }
        
        // MAB XXXXX RESTART CRASH WAS HERE DUE TO FLAME AND NUKE BEING ADDED 200 TIMES IN BULLET CACHE FOR LOOP INSTEAD
        // OF OUTSIDE.
        ///////////////////////////////////////
        // flamethrower
        ///////////////////////////////////////
        _flameThrowerGunModifier = [CCParticleSystemQuad particleWithFile:@"flameThrower.plist"];
        [_flameThrowerGunModifier stopSystem];
        //_flameThrowerGunModifier.duration = 3.0f;
        _flameThrowerGunModifier.duration = 0.5f;
        _flameThrowerGunModifier.speed *= 2;
        [self addChild:_flameThrowerGunModifier z:175];
        
        _flameThrowerBoundingSprite = [CCSprite spriteWithSpriteFrameName:@"flameCollisionSprite.png"];
        _flameThrowerBoundingSprite.visible = NO;
        
        [self addChild:_flameThrowerBoundingSprite];
        
        m_fSpriteBoundingTime = 0.0f;
        m_bFlameBoundingSpriteIsActive = NO;
        
        //////////////////////////////////////
        // NUKE
        //////////////////////////////////////
        _nukeGunModifier = [CCParticleSystemQuad particleWithFile:@"nukeEmitter.plist"];
        [_nukeGunModifier stopSystem];
        //_NukeGunModifier = 3.0f;
        _nukeGunModifier.duration = 0.5f;   // MAB XXXXX MAKE LONGER???
        _nukeGunModifier.speed *= 4;
        [self addChild:_nukeGunModifier z:0];
        // white rectangle
        _nukeBoundingSprite = [CCSprite spriteWithSpriteFrameName:@"flameCollisionSprite.png"];
        _nukeBoundingSprite.visible = NO;
        
        [self addChild:_nukeBoundingSprite];
        CCLOG(@"BULLET CACHE - end nuke");
        
        m_nSpriteBoundingTime = 0.0f;
        m_bNukeBoundingSpriteIsActive = NO;

    }
    CCLOG(@"BULLET CACHE - return self");
	return self;
}



-(Bullet *) getNextBullet:(NSString *)type{
    
    // break into types
    // TODO: SWITCH ON TYPES

    nextInactiveRegularBullet++;
    if(nextInactiveRegularBullet >= [_regularBullets count]){
        nextInactiveRegularBullet = 0; //reset our internal counter
    }
    
    _regularBullets = [_regularBulletBatch children];
    
    Bullet *bullet = [_regularBullets objectAtIndex:nextInactiveRegularBullet];
    
    
    return bullet;
}


// OBSOLETE
-(bool) isPlayerBulletCollidingWithRect:(CGRect)rect
{
	return [self isBulletCollidingWithRect:rect usePlayerBullets:YES];
}

-(BOOL) isPlayerBulletCollidingWithRect:(CGRect)rect gunModiferType:(GunModifiers)gunType
{
	return [self isBulletCollidingWithRect:rect usePlayerBullets:YES gunModiferType:gunType];
}

//-(bool) isEnemyBulletCollidingWithRect:(CGRect)rect
//{
//	return [self isBulletCollidingWithRect:rect usePlayerBullets:YES];
//}

-(void) shootBulletFrom:(CGPoint)startPosition velocity:(CGPoint)velocity frameName:(NSString *)frameName isPlayerBullet:(bool)isPlayerBullet{
    
    CCArray *bullets = [_regularBulletBatch children];
    CCNode *node = [bullets objectAtIndex:nextInactiveRegularBullet];
    NSAssert([node isKindOfClass:[Bullet class]],@"BULLETCACHE: NOT A BULLET!");
    Bullet *bullet = (Bullet*)node;
    [bullet shootBulletAt:startPosition velocity:velocity frameName:frameName isPlayerBullet:YES];
    
    nextInactiveRegularBullet++;
    if( nextInactiveRegularBullet >= [bullets count] ) {
        nextInactiveRegularBullet = 0;
    }
}

////////////////////////////////////////////////
// DIFFERENT GUN MODIFIERS
////////////////////////////////////////////////
-(void) shootBulletFrom:(CGPoint)startPosition velocity:(CGPoint)velocity frameName:(NSString *)frameName isPlayerBullet:(bool)isPlayerBullet currentGunModifier:(GunModifiers)modifierType rotation:(float)playerRotation{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCArray *bullets = [_regularBulletBatch children];
    
    // basic regular bullet
    if(modifierType == GunModifierBasic){
        CCNode *node = [bullets objectAtIndex:nextInactiveRegularBullet];
        NSAssert([node isKindOfClass:[Bullet class]],@"BULLETCACHE: NOT A BULLET!");
        Bullet *bullet = (Bullet*)node;
        [bullet shootBulletAt:startPosition velocity:velocity frameName:frameName isPlayerBullet:YES];
    
        nextInactiveRegularBullet++;
        if( nextInactiveRegularBullet >= [bullets count] ) {
            nextInactiveRegularBullet = 0;
        }
    }else if(modifierType == GunModifierDouble){
        CGFloat xPos = velocity.x;
        CGFloat yPos = velocity.y;
        for(int i = 0; i < kDoubleBulletAmount; i++){
            CCNode *node = [bullets objectAtIndex:nextInactiveRegularBullet];
            NSAssert([node isKindOfClass:[Bullet class]],@"BULLETCACHE: NOT A BULLET!");
            Bullet *bullet = (Bullet*)node;
            
            CGPoint newVelocity = CGPointMake(xPos, yPos);
            
            //startPosition.x += 8;
            [bullet shootBulletAt:startPosition velocity:newVelocity frameName:frameName isPlayerBullet:YES];
            nextInactiveRegularBullet++;
            if( nextInactiveRegularBullet >= [bullets count] ) {
                nextInactiveRegularBullet = 0;
            }
            
            if(velocity.y > -1 && velocity.y < 1){
                yPos += 10;
            }
            else{
                xPos += 10;
            }
            
        }
    }else if(modifierType == GunModifierHollowPoint){
       
        CCNode *node = [bullets objectAtIndex:nextInactiveRegularBullet];
        NSAssert([node isKindOfClass:[Bullet class]],@"BULLETCACHE: NOT A BULLET!");
        Bullet *bullet = (Bullet*)node;
        [bullet shootBulletAt:startPosition velocity:velocity frameName:@"bullet_2.png" isPlayerBullet:YES];
        
        nextInactiveRegularBullet++;
        if( nextInactiveRegularBullet >= [bullets count] ) {
            nextInactiveRegularBullet = 0;
        }

    }
    
    else if (modifierType == GunModifierTriple){
        // Triple Bullet Shootng
        CGFloat xPos = velocity.x;
        CGFloat yPos = velocity.y;
        for(int i = 0; i < kTripleBulletAmount; i++){
            CCNode *node = [bullets objectAtIndex:nextInactiveRegularBullet];
            NSAssert([node isKindOfClass:[Bullet class]],@"BULLETCACHE: NOT A BULLET!");
            Bullet *bullet = (Bullet*)node;
            
            // these x,y values get modified
            CGPoint newVelocity = CGPointMake(xPos, yPos);
            
            //startPosition.x += 8;
            [bullet shootBulletAt:startPosition velocity:newVelocity frameName:frameName isPlayerBullet:YES];
            nextInactiveRegularBullet++;
            if( nextInactiveRegularBullet >= [bullets count] ) {
                nextInactiveRegularBullet = 0;
            }
        
            // velocity x and y seem more like angles than coordinates
            if(velocity.y > -1 && velocity.y < 1){
                
                if(i == 0)
                    yPos += 10;
                if(i==1)
                    yPos -= 20;
            }
            else{
                
                if(i == 0)
                    xPos += 10;
                if(i==1)
                    xPos -= 20;
            }
            
            /*if(i == 0)
                xPos += 10;
            if(i==1)
                xPos -= 20;*/
            
        }
    } /*else if (modifierType == GunModifierFullAuto){
        CCNode *node = [bullets objectAtIndex:nextInactiveRegularBullet];
        NSAssert([node isKindOfClass:[Bullet class]],@"BULLETCACHE: NOT A BULLET!");
        Bullet *bullet = (Bullet*)node;
        [bullet shootBulletAt:startPosition velocity:velocity frameName:frameName isPlayerBullet:YES];
        
        nextInactiveRegularBullet++;
        if( nextInactiveRegularBullet >= [bullets count] ) {
            nextInactiveRegularBullet = 0;
        }
    } */else if(modifierType == GunModifierFlamethrower){

        // testing code, if works its final for flamethrower        
        _flameThrowerGunModifier.position = startPosition;

        // turn the particle system
        _flameThrowerGunModifier.rotation = [GameScene sharedGameScene].playerAngle;
        // reset the system
        [_flameThrowerGunModifier resetSystem];
        // THIS IS THE BOUNDING BOX. NEEDED FOR COLLISION DETECTION
        _flameThrowerBoundingSprite.position = startPosition;
        // Why the hell does this need to be such a small negative number t0 work?
        _flameThrowerBoundingSprite.anchorPoint = ccp(-0.005,-0.005);
        _flameThrowerBoundingSprite.scaleY = 2.5f;
        // XXXXX v1.1.1 Update - less of an X bounding box
        _flameThrowerBoundingSprite.scaleX = 0.65f;
        
        _flameThrowerBoundingSprite.rotation = [GameScene sharedGameScene].playerAngle;
        _flameThrowerBoundingSprite.visible = NO;
        
        
        m_bFlameBoundingSpriteIsActive = YES;
                
        
    }
    // NEW NUKE ADDED
    else if(modifierType == GunModifierNuke){
        // SHOW NUKE
        _nukeGunModifier.position = ccp(winSize.width/2, winSize.height/2);
        // reset the system
        [_nukeGunModifier resetSystem];
        // THIS IS THE BOUNDING BOX. NEEDED FOR COLLISION DETECTION
        _nukeBoundingSprite.position = CGPointZero;
        _nukeBoundingSprite.scaleY = 3.0f;
        _nukeBoundingSprite.scaleX = 26.0f;
        
        // show the bounding box
        _nukeBoundingSprite.visible = NO;
        //_nukeBoundingSprite.visible = YES;
        
        m_bNukeBoundingSpriteIsActive = YES;
    }
}

// OBSOLETE
-(bool) isBulletCollidingWithRect:(CGRect)rect usePlayerBullets:(bool)usePlayerBullets
{
	bool isColliding = NO;
	
	Bullet* bullet;
	CCARRAY_FOREACH([_regularBulletBatch children], bullet)
	{
		if (bullet.visible)// && usePlayerBullets == bullet.isPlayerBullet)
		{
			if (CGRectIntersectsRect([bullet boundingBox], rect))
			{
				isColliding = YES;
				                
				// remove the bullet
                
				bullet.visible = NO;
                [bullet setActiveStatus:NO];
				break;
			}
		}
	}
	
	return isColliding;
}

-(BOOL) isBulletCollidingWithRect:(CGRect)rect usePlayerBullets:(bool)usePlayerBullets gunModiferType:(GunModifiers)gunType
{
	bool isColliding = NO;
	
	Bullet* bullet;
	CCARRAY_FOREACH([_regularBulletBatch children], bullet)
	{
		if (bullet.visible)// && usePlayerBullets == bullet.isPlayerBullet)
		{
			if (CGRectIntersectsRect([bullet boundingBox], rect))
			{
				isColliding = YES;
                
				// remove the bullet
                
                if(gunType != GunModifierHollowPoint){
                    bullet.visible = NO;
                    [bullet setActiveStatus:NO];
                    break;
                }
			}
		}
	}
	
	return isColliding;
}

-(void) removeLabel: (id) sender
{
    [self removeChild:sender cleanup:YES];
    
}

-(void) updateFlameBoundingSpriteTimer:(ccTime)dt{
    
    //check to see if flame is active
    //increment time
    //if time is too long, remove active
    
    if(m_bFlameBoundingSpriteIsActive){
        m_fSpriteBoundingTime = dt + m_fSpriteBoundingTime;
        
        if(m_fSpriteBoundingTime >= kTimeForFlameBoundingSprite){
            m_bFlameBoundingSpriteIsActive = NO;
            _flameThrowerBoundingSprite.visible = NO;
            m_fSpriteBoundingTime = 0.0f;
        }
        
    }
}

@end










