//
//  EnemyEntity.h
//  ZombieTanks
//
//  Created by Corey Schaf on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"
#import "cocos2d.h"

@class ParticleEmitter;
@class GameScene;

typedef enum {
    
    BASIC_ZOMBIE = 0,
    BASIC_ZOMBIE_2 = 1,
    BASIC_ZOMBIE_3 = 2,
    SLOW_ZOMBIE = 3,
    BOSS_ZOMBIE_1 = 4,
    EnemyType_MAX
    
} EnemyTypes;

@interface EnemyEntity : Entity {
    
    CCSprite *_sprite;
    CCAction *_walkAction;
    CCAnimation *_walkAnimation;
    
    CCParticleSystemQuad *bloodSystem;
    
    // depreciated
    CCRotateTo *_rotateAction;
    
    int _speed;
    int _health;
    int _staticHealth;
    int _damage;
    
    
    CGPoint _position;
    CGPoint _targetPosition;
    CGRect _absoluteBoundingBox;
    
    BOOL _active;
    
    GameScene *_layer;
    
    ccTime _frameInterval;
    
    EnemyTypes _type;
    CCLabelTTF *_score;
    
}

@property (readonly, nonatomic) int speed;
@property (strong) CCSprite* sprite;
@property (strong) CCAction* walkAction;
@property (assign) BOOL moving;
@property (assign) BOOL active;
@property (readonly) CGRect absoluteBoundingBox;
@property (readonly) EnemyTypes type;
@property (readwrite,retain) CCParticleSystem *emitter;
@property (readwrite) int health;

+(int) getEnemySpawnAmountPerType:(EnemyTypes)type;
+(int) getEnemyAttackDamage:(EnemyTypes)type;
+(int) getEnemyKillPoints:(EnemyTypes)type;


+(id) enemyWithType:(EnemyTypes) type withLayer:(GameScene *)layer;
+(id) enemyWithType:(EnemyTypes) type;

-(id) initWithType:(EnemyTypes) type withLayer:(GameScene *)layer;
-(id) initWithType:(EnemyTypes)type;

-(void) gotShot:(int)damage;
-(void) setVisibleStatus:(BOOL) visibility;
-(void) setPosition:(CGPoint) position;
-(void) move:(ccTime)dt;
-(void) calcNextMove;
-(void) moveToward:(CGPoint)targetPosition;
-(BOOL) clearPathFromTileCoord:(CGPoint)start toTileCoord:(CGPoint)end;
-(void) setPosition:(CGPoint)position;
-(void) updateAbsoluteBoundingBoxRect;
-(void) setRandomSpawnPoint;
-(void) playBloodSystem;
-(void) spawnSelf;
-(void) showScore:(NSString*)points;
@end









