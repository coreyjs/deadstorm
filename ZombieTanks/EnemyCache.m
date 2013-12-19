//
//  EnemyCache.m
//  ZombieTanks
//
//  Created by Corey Schaf on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnemyCache.h"
#import "EnemyEntity.h"
#import "BulletCache.h"
#import "GameScene.h"

@interface EnemyCache (PrivateMethods)

-(void) initEnemies;

@end

@implementation EnemyCache

+(id) cache{
    
    return [[self alloc] init];
}

-(id) init{
    
    if( (self = [super init])){
        
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"basic_zombie_1.png"];
        _enemyCacheSpriteBatchNode = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
       
        [self initEnemies];
        [self addChild:_enemyCacheSpriteBatchNode];
        //[self scheduleUpdate];
        [[[CCDirector sharedDirector] scheduler] scheduleUpdateForTarget:self priority:0 paused:NO];

        
    }
    
    return self;
}

-(void)initEnemies{

    // create the enemies array containing further arrays for each type
    _enemies = [[CCArray alloc] initWithCapacity:EnemyType_MAX];
    for(int i = 0; i < EnemyType_MAX; i++){
        
        // depending on enemy type the array capacity is set to hold the desired number of enemies
        int capacity;
        switch(i){
            case BASIC_ZOMBIE:
                capacity = 6;
                break;
            case BASIC_ZOMBIE_2:
                capacity = 6;
                break;
            case BASIC_ZOMBIE_3:
                break;
            case SLOW_ZOMBIE:
                capacity = 3;
                break;
                
            default:
                [NSException exceptionWithName:@"Enemy Cache Exception" reason:@"unhandled enemy type" userInfo:nil];
                break;
        }
        
        // no alloc needed since the enemies will retain anyhthing added to it
        CCArray *enemiesOfType = [CCArray arrayWithCapacity:capacity];
        [_enemies addObject:enemiesOfType];
        
    }

    for(int i = 0; i < EnemyType_MAX; i++){
        CCArray *enemiesOfType = [_enemies objectAtIndex:i];
        int numEnemiesOfType = [enemiesOfType capacity];
        
        for(int j = 0; j < numEnemiesOfType; j++){
            
            EnemyEntity *enemy = [EnemyEntity enemyWithType:i];
            [_enemyCacheSpriteBatchNode addChild:enemy.sprite z:0 tag:i];
            [enemiesOfType addObject:enemy];
        }
    }
}

-(void) spawnEnemyOfType:(EnemyTypes)enemyType{
    
    // [0] basic, [0] other basic....[3] slow
    CCArray *enemiesOfType = [_enemies objectAtIndex:enemyType];
    EnemyEntity *enemy;
    CCARRAY_FOREACH(enemiesOfType, enemy){
        
        if(enemy.sprite.visible == NO){
            
            CCLOG(@"spawn enemy of type %i", enemyType);
            [enemy spawnSelf];
            break;
        }
    }
}

-(void) checkForBulletCollision{
    
    EnemyEntity *enemy;
    CCARRAY_FOREACH([_enemyCacheSpriteBatchNode children], enemy.sprite){
        
        if(enemy.sprite.visible){
        
        BulletCache *bulletCache = [GameScene sharedGameScene].bulletCache;
        CGRect bbox = [enemy.sprite boundingBox];
        
            if( [bulletCache isPlayerBulletCollidingWithRect:bbox]){
                
                [enemy gotShot:1];
                [enemy playBloodSystem];
                
                if([enemy health] <= 0){
                    
                    [[GameScene sharedGameScene] updateKillStreak:1];
                    [[GameScene sharedGameScene] setPointMultiplier];
                    [GameScene sharedGameScene].totalKillCount += 1;
                    
                    int killScore = (50 * [GameScene sharedGameScene].pointMultiplier);
                    
                    [GameScene sharedGameScene].score += killScore;
                    
                    //NSString *killScoreStr = [NSString stringWithFormat:@"%02d", killScore];
                    
                    if([GameScene sharedGameScene].totalKillCount % 10 == 0){
                        
                        [[GameScene sharedGameScene] spawnMedkit:enemy.sprite.position];
                    }
                }
                
            }
        }
    }
}

-(void) update:(ccTime) dt{
    
    _updateCount++;
    
    for(int i = EnemyType_MAX - 1; i >= 0; i--){
        
        int spawnFreq = [EnemyEntity getEnemySpawnAmountPerType:i];
        
        if(_updateCount % spawnFreq == 0){
            CCLOG(@"Spawn Zombie");
            [self spawnEnemyOfType:i];
            break;
        }
    }
    
    [self checkForBulletCollision];
}

@end

































