//
//  GameScene.h
//  ZombieTanks
//
//  Created by Corey Schaf on 1/26/12.
//  Copyright 2012 blaQk Sheep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

@class Player;
@class HUDLayer;
@class EnemyEntity;
@class BulletCache;
@class AudioManager;
@class HealthEnhancement;
@class GunEnhancment;
@class EnemyCache;

typedef enum{
    kEndReasonWin,
    kEndReasonLose
} EndReson;

typedef enum{
    HUD = 0,
    GameObjectPause = 1,
    GameObjectBulletCache = 2,
    GameObjectHealthKit = 3,
    GameObjectEnemyCache = 4,
    GameObjectGunPickup = 5,
    GameObjectEnemy = 6
}LayerObjects;

typedef enum{
    killStreakLevel1,
    killStreakLevel2,
    killStreakLevel3,
    killStreakLevel4,
    killStreakLevel5,
    killStreakLevel6,
    killStreakLevel7,
    killStreakLEvel8
}KillStreak;


@interface GameScene : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate> {
    

    int _totalGameScore;
    
    BOOL _gameOver;
    CCSprite *_exit;
    
    HUDLayer *_hudLayer;
    
    EnemyEntity *_enemy_temp_1;
    EnemyEntity *_enemy_temp_2;
    
    CCArray *_basicDebugEnemies;
    CCArray *_basic_enemy2Array;
    CCArray *_basic_enemy3Array;
    CCArray *_slow_enemyArray;
    
    ccTime totalTime;
    ccTime spawnEnemy;
    ccTime timeSinceLastSpawn;
    
    
    CGSize winSize;
    
    CCLayerColor *_pauseMenuBackground;
    CCMenu *_pauseMenu;
    BOOL gotHitAnimationPlaying;
    BOOL _isPaused;
    BOOL _isIntro;
    float _invulnerableTime;
    BOOL _runHitAnimation;
    BOOL _hitAnimationIsPlaying;
    // main screen when starting a new game
    CCLayerColor *_introSplashLayer;

    AudioManager *m_audioManager;
    
    int _killStreak;
    int _pointMultiplier;
    CCArray *_spriteMultipliers;
    
    float invulnerableTime;
    
    // GAME TRACKING VARIABLES
    int _totalZombiesKilled;
    int _totalShotsFired;
    ccTime _totalGameTimePlayed;
    
    // random pickups
    CCArray *_healthPickups;
    int _nextInactiveHealthPickup;
    
    // revamped enemy respawn variables
    float _respawnInterval;
    
    // variables for handling acceleromter calibration
    float _accelerationX;
    float _accelerationY;
    
    CCArray *_gunEnhancementPickups;
    int _nextInactiveGunEnhancementPickup;
    
    
    // Achievement helper variables
    BOOL m_bFirstMedKit;
    BOOL m_bFirstAmmoBox;
    BOOL m_bFirstMultiplier;
    BOOL m_bSurvived20SecondsNoDamage;
    int m_iMedKitUsageCount;
    float m_fTimeSpentWithUnder10Health;
    
    BOOL m_bFirstGameFinished;
    BOOL m_bDiedWithNoKils;
    
    BOOL m_bIsHighScore;
    
    // GUn Pickup notification
    //CCLabelTTF *_gunPickupNotificationLabel;
    CCLabelBMFont *_gunPickupNotificationLabel;
    
    //temp var for handling flamethower angle
    float m_fAngleOfPlayer;
    
    // gun unlock notification
    CCLabelBMFont *_gunUnlockNotificationLabel;
    
    // Boss logic variables
    BOOL m_bIsBossFight;
    float m_fBossBattleBeginTimer;
    float m_fTimeToBeginBossFight;
    int m_iBossCounter;
    float m_fTotalBossTime;
    float m_fTimeFightingBoss;
}

@property (strong) Player *player;
@property (strong) CCSpriteBatchNode *batchNode;
@property (strong) CCSpriteBatchNode *playerBatchNode;
@property (readonly, nonatomic) BulletCache* bulletCache;
@property (readwrite) int totalKillCount;
@property (readwrite) int pointMultiplier;
@property (readwrite) int score;
@property (readonly) float playerAngle;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
+(GameScene*) sharedGameScene;
+(void)pause;

+(CGRect) screenRect;

- (id)initWithHUDLayer:(HUDLayer *)hudLayer;
- (BOOL)isValidPosition:(CGPoint)position;
- (BOOL)isProp:(NSString*)prop atPosition:(CGPoint)position forLayer:(CCTMXLayer *)layer;
- (BOOL)isWallAtTileCoord:(CGPoint)tileCoord;
- (BOOL)isWallAtPosition:(CGPoint)position;
- (BOOL)isWallAtRect:(CGRect)rect;
- (void)endScene:(EndReson)endReason;
- (void)spawnEnemy;
- (void) PlayerGotHit;
- (CGPoint) getPlayerLocation;
- (CGPoint) locationFromTouch:(UITouch *)touch;
- (void) setPointMultiplier;
- (int) updateKillStreak:(int)amount;
- (void) spawnMedkit:(CGPoint)position;
- (void) spawnGunEnhancment:(CGPoint)position;
- (void) pauseGame;
- (void) activeFlamethrower;

float SquareDistance(float x1, float y1, float x2, float y2);

@end
