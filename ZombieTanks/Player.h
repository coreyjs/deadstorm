//
//  Player.h
//  ZombieTanks
//
//  Created by Corey Schaf on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GunModifierComponent.h"

@class GameScene;
@class BulletCache;
@class GunModifierComponent;

@interface Player : CCSprite{
    
    //CCSprite *_sprite;
    
    
    GameScene *_layer;
    
    CGPoint _targetPosition;
    CGPoint _shootVector;
    
    double _timeSinceLastShot;
    
    CCSprite *_playerSprite;
    CCAnimation *_playerAnimation;
    CCAnimate *_animation;
    
  //  CCArray *_regularBullets;
  //  int _nextInactiveRegularBullet;
    
   // BulletCache *bulletCache;
    
    float spriteWidth;
    float spriteHeight;
    
    ccTime _timeSinceLastTookDamage;
    ccTime _invincibileTime;
    // temporary invulnerability just after being hit
    BOOL _canBeDamaged;
    
    CCParticleSystemQuad *_healthSystem;
    CCParticleSystemQuad *bloodSystem;
    
    CCBlink *_blink;
    float m_bBlinkControlFlag;
    
    // PLAYER SPEED (will get reduced when badly hurt)
    float _playerSpeed;
    
    // control variables for random gun pickups
    int m_iTotalShotsFired;
    int m_iMaxShotsToBeFired;
    
    CGRect _absoluteBoundingBox;
    
    // obsolete
    CCParticleSystemQuad *_flameThrowerGunModifier;
}

@property (assign) BOOL moving;
@property (assign) int health;
@property (assign) float speed;
@property (assign) BOOL isShooting;
@property (strong) CCArray *regularProjectiles;
@property (assign) int lives;
@property (assign) GunModifiers gunModifierType;
@property (readonly) CGRect absoluteBoundingBox;

-(void) setVisibleStatus:(BOOL) visibility;
-(id)initWithLayer:(GameScene *)layer type:(int)type hp:(int)hp;
-(void)moveToward:(CGPoint)targetPosition;
-(void)shootToward:(CGPoint)targetPosition;
-(void)shootNow;
-(void)updateShoot:(ccTime)dt;
-(BOOL)shouldShoot;
-(BOOL) gotHit:(int)dmg;
-(void) playHealthSystem;
-(void) addHealth:(int)hp;
-(void) Blink:(int)howLong;
-(void) gotHitAnimations;
-(void) removeLabel: (id) sender;
-(void) resetBulletTracker;
-(void) updateAbsoluteBoundingBox;
-(CGRect *) flamethrowerEnabled;
-(void) playBloodSystem;


@end
