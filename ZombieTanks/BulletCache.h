//
//  BulletCache.h
//  ShootEmUp
//
//  Created by Steffen Itterheim on 18.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GunEnhancment.h"

@class Bullet;

@interface BulletCache : CCNode 
{
	CCSpriteBatchNode* _regularBulletBatch;
	int nextInactiveRegularBullet;
    //CCArray *_regularBullets;
    
    CCSpriteBatchNode *_superBulletBatch;
    int nextInactiveSuperBullet;
    
    CCParticleSystemQuad *_flameThrowerGunModifier;
    CCSprite *_flameThrowerBoundingSprite;
    float m_fSpriteBoundingTime;
    BOOL m_bFlameBoundingSpriteIsActive;
    // NEW NUKE
    CCParticleSystemQuad *_nukeGunModifier;
    CCSprite *_nukeBoundingSprite;
    float m_nSpriteBoundingTime;
    BOOL m_bNukeBoundingSpriteIsActive;
}

@property (strong) CCArray *regularBullets;

@property (readonly) CCParticleSystemQuad *flameThrowerSystem;
@property (strong) CCSprite *flameThrowerBoundingSprite;
@property BOOL flameBoundingActive;

@property (strong) CCSprite *nukeBoundingSprite;
@property BOOL nukeBoundingActive;

-(Bullet *) getNextBullet:(NSString *)type;
-(bool) isPlayerBulletCollidingWithRect:(CGRect)rect;

-(BOOL) isPlayerBulletCollidingWithRect:(CGRect)rect gunModiferType:(GunModifiers)gunType;

-(void) shootBulletFrom:(CGPoint)startPosition velocity:(CGPoint)velocity frameName:(NSString*)frameName isPlayerBullet:(bool)isPlayerBullet;

-(void) shootBulletFrom:(CGPoint)startPosition velocity:(CGPoint)velocity frameName:(NSString*)frameName isPlayerBullet:(bool)isPlayerBullet currentGunModifier:(GunModifiers)modifierType;

-(void) shootBulletFrom:(CGPoint)startPosition velocity:(CGPoint)velocity frameName:(NSString*)frameName isPlayerBullet:(bool)isPlayerBullet currentGunModifier:(GunModifiers)modifierType rotation:(float)playerRotation;

-(void) updateFlameBoundingSpriteTimer:(ccTime)dt;

@end
