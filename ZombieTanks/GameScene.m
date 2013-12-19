//
//  GameScene.m
//  ZombieTanks
//
//  Created by Corey Schaf on 1/26/12.
//  Updated by Michael Bielat on 7/13/2012.

// TODO: Add heartbeat audio to coordinate with the Survive button.

//  Copyright 2012 blaQk Sheep. All rights reserved.
//

#import "GameScene.h"
#import "SceneManager.h"
#import "Player.h"
#import "SimpleAudioEngine.h"
#import "HUDLayer.h"
#import "EnemyEntity.h"
#import "Bullet.h"
#import "BulletCache.h"
#import "MenuScene.h"
#import "AudioManager.h"
#import "DataSystemsManager.h"
#import "ScoreManager.h"
#import "SimpleAudioEngine.h"
#import "HealthEnhancement.h"
#import "AudioToolbox/AudioToolbox.h"
#import "GunEnhancment.h"
#import "GCHelper.h"
#import "GameState.h"
//#import "IAdHelper.h"
#import "InAppDeadstormHelper.h"
// CALIBRATION CODE
//#import "CalibrationScene.h"
//#import "AcceleratableLayer.h"


@interface GameScene(PrivateMethods)

-(BOOL) isTouchForPause:(CGPoint)touchLocation;
-(void) countBullets:(ccTime)delta;
-(EnemyTypes) getEnemySpawnType;
-(int) getGunUnlockTypeFromAchievementCount;
-(void) SaveGameStats;
-(void) determineInGameAchivemmentGameState;
-(void) determineOverallAchievementGameStateWithTotalKills:(int)kills timePlayed:(ccTime)timePlayed withPoints:(int)totalPoints;
-(void) showGunPickupLabel:(NSString*)name;
-(void) removeGunLabel: (id) sender;

@end

@implementation GameScene

#define MAX_BASIC_ENEMY         32
#define MAX_HEALTH_PICKUPS      10
#define MAX_GUN_PICKUPS         10
#define MAX_BOSS_1_ENEMY        4
// ADDED for quick game play changes with ease.
#define MEDKIT_PICKUP_RATE 40 // this triggers how many kills drop a medkit

#define AMMO_PICKUP_RATE 25   // this triggers how many kills drop a gun modifier

#define STARTUP_EASY_PLAY_TIME 10 // how long do we give the player before switching from an easy respawn rate over to a tougher one?

#define INV_MAX_LONGINT                 2.328306e-10f
static unsigned long z = 362436069, w = 521288629;
#define znew()      ((z = 36969 * (z & 65535) + (z >> 16)) << 16)
#define wnew()      ((w = 18000 * (w & 65535) + (w >> 16)) & 65535)
#define IUNI()      (znew() + wnew())
#define UNI()       ((znew() + wnew()) * INV_MAX_LONGINT)

// global and only call once then set it to false.
static BOOL calibrationFlag = YES;
// center for calibration
CGPoint cenpt;
float biasX;
float biasY;

float lastAccelX;
float lastAccelY;

CGPoint playerVelocity;

BOOL adjustForBias;

float calibration = 0.0f;
float calibrationy = 0.0f;

static void setseed(unsigned long i1, unsigned long i2) { z=i1; w=i2; }

static CGRect screenRect;
static GameScene * sharedInstance = nil;


@synthesize batchNode = _batchNode;
@synthesize player = _player;
@synthesize playerBatchNode = _playerBatchNode;
@synthesize playerAngle = m_fAngleOfPlayer;

+(GameScene *) sharedGameScene{
    
    if(sharedInstance != nil){
        return sharedInstance;
    }
    
    return nil;
}

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    // this is the ground.
//    CCSprite* background = [CCSprite spriteWithFile:@"grating-bkgd2.png"];
//    background.tag = 3;
//    background.anchorPoint = CGPointMake(0, 0);
//    [scene addChild: background z:0];
    
    
    HUDLayer *_hud = [HUDLayer node];
    [scene addChild:_hud z:1 tag:HUD];
    
	// 'layer' is an autorelease object.
	GameScene *layer = [[GameScene alloc] initWithHUDLayer:_hud];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    
    sharedInstance = layer;
	// return the scene
	return scene;
}

+(void)pause{
    if(sharedInstance != nil){
        [sharedInstance pauseGame];
       // [[CCDirector sharedDirector] pause];
    }
}

+(CGRect) screenRect
{
	return screenRect;
}


- (BOOL)isWallAtRect:(CGRect)rect {
    CGPoint lowerLeft = ccp(rect.origin.x, rect.origin.y);
    CGPoint upperLeft = ccp(rect.origin.x, rect.origin.y+rect.size.height);
    CGPoint lowerRight = ccp(rect.origin.x+rect.size.width, rect.origin.y);
    CGPoint upperRight = ccp(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    
    return ([self isWallAtPosition:lowerLeft] || [self isWallAtPosition:upperLeft] ||
            [self isWallAtPosition:lowerRight] || [self isWallAtPosition:upperRight]);
}

// on "init" you need to initialize your instance
-(id) initWithHUDLayer:(HUDLayer *)hudLayer{
	if((self = [super init])){
        
        //accelLayer = [[AcceleratableLayer alloc] init];
    
        //[[CCDirector sharedDirector] setDeviceOrientation:kCCDeviceOrientationPortrait];
        
        [[CCDirector sharedDirector] resume]; // odd bug, this should fix it MAB
        // give invulnerable time a value
        _invulnerableTime = 0;
        
        /*
         if( ![[InAppDeadstormHelper sharedHelper] productPurchased:kDeadStormRemoveAdsIdentifier] ){
            [[IAdHelper sharedInstance] moveBannerOnScreen];
        }
         */
        
        //[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
        winSize = [[CCDirector sharedDirector] winSize];
        screenRect = CGRectMake(0, 0, winSize.width, winSize.height);
        // FOR CALIBRATION
        cenpt = ccp(winSize.width*0.5f,winSize.height*0.5f);
        _hudLayer = hudLayer;
        
        // Load all of the game's artwork up front.
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB888];
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"gamesprites.pvr.ccz"  capacity:200]; // MAB XXXXX DOES THIS CAPACITY BREAK ANYTHING? I ADDED IT - pre restart fix. trying to fix.
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gamesprites.plist"];
        
        CCSprite* background;// = [CCSprite spriteWithFile:@"grating-bkgd2.png"];
        
        if(winSize.width == 568){
            background = [CCSprite spriteWithFile:@"grating-bkgd2-5-hd.png"];
        }else{
            background = [CCSprite spriteWithFile:@"grating-bkgd2.png"];
        }
        
        background.tag = 3;
        background.anchorPoint = CGPointMake(0, 0);
        [self addChild: background z:0];
        
        CGPoint spawnPos = ccp(winSize.width/2, winSize.height/2);
        
        //[self setViewpointCenter:spawnPos];
        [self addChild:_batchNode];
        
        self.player = [[Player alloc] initWithLayer:self type:1 hp:100];
        self.player.position = spawnPos;
        [_batchNode addChild:self.player];
        
        _killStreak = 0;
        _pointMultiplier = 1;
        
        
        CGPoint enemyDebugSpawn = spawnPos;
        enemyDebugSpawn.y += -75;
        
        // DEBUG MANY ZOMBIES
        
        _basicDebugEnemies = [[CCArray alloc] initWithCapacity:MAX_BASIC_ENEMY];// + MAX_BOSS_1_ENEMY];
      
        for(int i = 0; i < MAX_BASIC_ENEMY; i++){
                    
            EnemyEntity *enemy = [EnemyEntity enemyWithType:BASIC_ZOMBIE withLayer:self];
            [_batchNode addChild:enemy.sprite z:1 tag:GameObjectEnemy];
            [_basicDebugEnemies addObject:enemy];
        }
        
        // fill boss  32 + 4
        for(int i = 0; i < MAX_BOSS_1_ENEMY; i++){
            EnemyEntity *enemy = [EnemyEntity enemyWithType:BOSS_ZOMBIE_1 withLayer:self];
            [_batchNode addChild:enemy.sprite z:1 tag:GameObjectEnemy];
            [_basicDebugEnemies addObject:enemy];
        }

        // XXXXX array of medkits for health
        _nextInactiveHealthPickup = 0;
        _healthPickups = [[CCArray alloc] initWithCapacity:MAX_HEALTH_PICKUPS];
        for(int i = 0; i < MAX_HEALTH_PICKUPS; i++){
            
            HealthEnhancement *_healthEnhancement = [HealthEnhancement healthEnhancementWithHealth:10 withLayer:self];
            [_healthPickups addObject:_healthEnhancement];
            [_batchNode addChild:_healthEnhancement.sprite z:10 tag:GameObjectHealthKit];
        }
        
        // Gun Enhancement pickups
        _nextInactiveGunEnhancementPickup = 0;
        _gunEnhancementPickups = [[CCArray alloc] initWithCapacity:MAX_GUN_PICKUPS];
        for(int j = 0; j < MAX_GUN_PICKUPS; j++){
            // this will be random, based on guns already unlocked
         
            // similar to _gType = arc4tan % [self getGunTypeByAchievementAmount]
            //GunModifiers _gType = GunModifierDouble;
//            GunModifiers _gType = (arc4random() % [self getGunUnlockTypeFromAchievementCount]) + 1;
            ///////////////////////////////////////////////
            // Get unlock for the NUKE!!!
            // If the player paid for the in-app purchase then they can unlock nuke
            GunModifiers _gType;
            /*
             if( ![[InAppDeadstormHelper sharedHelper] productPurchased:kDeadStormRemoveAdsIdentifier] ){
                _gType = (arc4random() % 4) + 1;
            }
            else{
             */
            _gType = (arc4random() % 5) + 1; // UNLOCK THE NUKE IF THEY PAID!
            //}
            
            /////////////////////////////////////////////////
            // original no nuke
            //GunModifiers _gType = (arc4random() % 4) + 1;
            
            //CCLOG(@"Init gun mod");
            GunEnhancment *_gunEnhancement = [GunEnhancment gunEnhancementWithType:_gType
                                                                         withLayer:self];

            [_gunEnhancementPickups addObject:_gunEnhancement];
            [_batchNode addChild:_gunEnhancement.sprite z:10 tag:GameObjectGunPickup];            
        }

        // Init pause objects and add to scene
        CCSprite *pause = [CCSprite spriteWithSpriteFrameName:@"pauseButtonBlood.png"];
        pause.position = CGPointMake(0 , winSize.height);
        pause.anchorPoint = CGPointMake(0, 1);
        
        [self addChild:pause z:2 tag:10];
        
        spawnEnemy = 5;
        timeSinceLastSpawn = 0;
        _totalGameScore = 0;

        // set defualt pixil format
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // initialize the hud layer, and add to scene
        [_hudLayer setHp:self.player.health];
        
        
        // Bullet Cache init and add to parent
        BulletCache *bulletCache = [BulletCache node];
    
        [self addChild:bulletCache z:1  tag:GameObjectBulletCache];
        
        // Not needed right now code
        //[self setViewpointCenter:self.player.position];
        
        // enable touch capabilities
        self.touchEnabled = YES;
        
        [self unschedule:@selector(update:)];
        [self scheduleUpdate];
        
        // ****************************************
        
        // build the intro screen we see when
        // we first begin the game
        _introSplashLayer = [CCLayerColor layerWithColor:ccc4(1,1,1,1)];
        CCSprite *m_introSpriteBackground = [CCSprite spriteWithSpriteFrameName:@"instructions_screen.png"];
        [m_introSpriteBackground setPosition:CGPointMake(winSize.width * 0.5f, winSize.height*0.5)];
        [_introSplashLayer addChild:m_introSpriteBackground z:6];
        [self addChild:_introSplashLayer z:5];
        
        CCMenu *m_splashMenu;
        //////////////////////////////////////////
        // SURVIVE BUTTON
        //////////////////////////////////////////
        CCMenuItemImage *m_splashPlayImage = [CCMenuItemImage itemWithNormalImage:@"SurviveButton2.png" selectedImage:@"SurviveButton2.png" target:self selector:@selector(beginGame:)];
        
        
        id scaleUpAction =  [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.4 scaleX:1.0 scaleY:1.0] rate:1.0];
        id scaleDownAction = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.4 scaleX:0.95 scaleY:0.95] rate:1.0];
        CCSequence *scaleSeq = [CCSequence actions:scaleUpAction, scaleDownAction, nil];
        [m_splashPlayImage runAction:[CCRepeatForever actionWithAction:scaleSeq]];
        
        //[m_splashPlayImage setOpacity:1.0];
        CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.4 opacity:127];
        CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.4 opacity:255];
        
        CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
        [m_splashPlayImage runAction:repeat];
        
        SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
        
        //[sae playBackgroundMusic:@"DS_Song.mp3" loop:YES];   // added loop
        //sae.backgroundMusicVolume = 0.3f;                    // adjust sound volume
        CCLOG(@"MAB TEST 2");
        
        [sae playBackgroundMusic:@"heartbeat1.mp3" loop:YES];   // added loop
        //sae.backgroundMusicVolume = 0.3f;                    // adjust sound volume
        [sae playEffect:@"heavyBreathing.wav"];
        
        m_splashMenu = [CCMenu menuWithItems:m_splashPlayImage, nil];
        [m_splashMenu setPosition:CGPointMake(winSize.width*0.5, winSize.height*.20 )];
        
        [_introSplashLayer addChild:m_splashMenu z:6];
        
        //////////////////////////////////////////
        // END SURVIVE BUTTON
        //////////////////////////////////////////
        
        
        //////////////////////////////////////////
        // BUY NUKE BUTTON
        //////////////////////////////////////////
        /*
        CCMenuItemImage *m_splashPlayImage = [CCMenuItemImage itemWithNormalImage:@"SurviveButton2.png" selectedImage:@"SurviveButton2.png" target:self selector:@selector(beginGame:)];
        
        m_splashMenu = [CCMenu menuWithItems:m_splashPlayImage, nil];
        [m_splashMenu setPosition:CGPointMake(winSize.width*0.5, winSize.height*.20 )];
        
        [_introSplashLayer addChild:m_splashMenu z:6];
        */
        //////////////////////////////////////////
        // BUY NUKE BUTTON
        //////////////////////////////////////////
        
        
        
        //add splash into menus
        //uncomment when we add the intro splash screen
        //[[CCDirector sharedDirector] pause];
        _isIntro = YES;
        // *****************************************
        
        // [self initSpriteMultipliers];
        
        _totalGameTimePlayed = 0;
        _totalShotsFired = 0;
        _totalGameTimePlayed = 0.0f;
        _totalZombiesKilled = 0;
        // respawn variables
        _respawnInterval = 0.6;
        

        // Achievement Variables
        m_bFirstMedKit = NO;
        m_bFirstAmmoBox = NO;
        m_bFirstMultiplier = NO;
        m_bSurvived20SecondsNoDamage = YES;
        m_iMedKitUsageCount = 0;
        m_fTimeSpentWithUnder10Health = 0;
        m_bFirstGameFinished = NO;
        m_bDiedWithNoKils = NO;
        
        m_bIsHighScore = NO;
        
        // gun pickup notifications
        _gunPickupNotificationLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"planecrash_18_white.fnt"];
        _gunPickupNotificationLabel.visible = NO;
        [self addChild:_gunPickupNotificationLabel z:101];
        
        m_fAngleOfPlayer = self.player.rotation;
        
        _gunUnlockNotificationLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"planecrash_18_white.fnt"];
        _gunUnlockNotificationLabel.visible = NO;
        [self addChild:_gunUnlockNotificationLabel z:102];
        
        
        // instatiation of boss fight variables
        
        m_iBossCounter = 1; // we increase this every minutes with more bosses
        m_fBossBattleBeginTimer = 0.0f;
        m_bIsBossFight = NO;
        m_fTimeToBeginBossFight = 27.0f;
        m_fTotalBossTime = 10.0f;
        m_fTimeFightingBoss = 0.0f;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0/30];
        
       // [[UIAccelerometer sharedAccelerometer] ]
        
        //[[IAdHelper sharedInstance] moveBannerOffScreen];
        
    }
    
    return self;
}

-(BulletCache*) bulletCache
{
	CCNode* node = [self getChildByTag:GameObjectBulletCache];
	NSAssert([node isKindOfClass:[BulletCache class]], @"not a BulletCache");
	return (BulletCache*)node;
}

-(bool) isTouchForPause:(CGPoint)touchLocation
{
    if(!_isIntro){
        CCNode* node = [self getChildByTag:10];
        return CGRectContainsPoint([node boundingBox], touchLocation);
    }else{
        return NO;
    }
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (_gameOver) return;
    if(_isIntro) return;
    
    UITouch *touch = [touches anyObject];
    //CGPoint mapLocation = [_tileMap convertTouchToNodeSpace:touch];
    CGPoint screenLocation = [self convertTouchToNodeSpace:touch];
    
    BOOL isPauseTouch = [self isTouchForPause:screenLocation];
    if(isPauseTouch){
        [self pauseGame];
    }
    
    float angle = CC_RADIANS_TO_DEGREES(atan2(_player.position.y - screenLocation.y,
                                              _player.position.x - screenLocation.x));
    
    angle += 90;
    angle *= -1;
    
    
    
    //float angleRadians = CC_DEGREES_TO_RADIANS(angle);
    
    //float rotateSpeed = 0.2 / M_PI; // Would take 0.5 seconds to rotate 0.5 radians, or half a circle
    //float rotateDuration = fabs(angleRadians * rotateSpeed);
    
    CCLOG(@"CurrentPlayer Roatation: %f", self.player.rotation);
    
    [_player stopAllActions];
    [_player runAction:[CCSequence actions: [CCRotateTo actionWithDuration:0 angle:angle] , nil]];
    
    CCLOG(@"Player Angle of Action For CCAction: %f", angle);
    CCLOG(@"CurrentPlayer After Action Roatation: %f", self.player.rotation);
    
    [self.player setRotation:angle];
    
    m_fAngleOfPlayer = angle;
    
    self.player.isShooting = YES;
    [self.player shootToward:screenLocation];
    _totalShotsFired++;
}

// ****************** TOUCH EVENTS ****************************
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if(_gameOver) return;
    if(_isIntro) return;
    
    //if(self.player.gunModifierType != GunModifierFullAuto)
        self.player.isShooting = NO;
}

-(void) ccTouchsEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if(_gameOver) return;
    if(_isIntro) return;
    
    //if(self.player.gunModifierType != GunModifierFullAuto)
        self.player.isShooting = NO;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CCLOG(@"In ccToucheCanclled");
    if(_isIntro) return;
    // call touch ended method to cover our all bases for ending touches
    [self ccTouchEnded:touch withEvent:event];
}
-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CCLOG(@"In ccTouchesCanclled");
    if(_isIntro) return;
    [self ccTouchesCancelled:touches withEvent:event];
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //    if (_gameOver) return;
    //
    //    UITouch *touch = [touches anyObject];
    //    CGPoint mapLocation = [_tileMap convertTouchToNodeSpace:touch];
    //
    //    // TODO: YES OR NO, HOW TO HANDLE TOUCH DRAGS
    //    self.player.isShooting = NO;
    //    [self.player shootToward:mapLocation];
}


// *************** END TOUCH EVENTS *******************

-(void) onEnterTransitionDidFinish{
    
    self.accelerometerEnabled = YES;
    self.touchEnabled = YES;
    
}

-(CGPoint) easeInExp:(CGPoint)t b:(float)b c:(float)c d:(float)d
{
    CGPoint pos;
    pos.x = c * powf(2.0f, 10.0f * (t.x / d - 1.0f)) + b;
    pos.y = c * powf(2.0f, 10.0f * (t.y / d - 1.0f)) + b;
    return pos;
}

#define kFilteringFactor 0.25
// XXXXX v1.1.1 update now defines for quicker multiplication and hopefully better speed
#define upDownMultiplier    3
#define leftRightMultiplier 2


// now using player.speed variable and getting hurt under 25% makes player slower
//#define kPlayerSpeed 10
#define kAccelerometerMesaure 0.15
#define kAccelerometerMeasureY 0.15

-(CGRect) allowableMovementArea
{
    
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
    /*
	float imageWidthHalved = [_player contentSize].width * 0.5f;
	float leftBorderLimit = imageWidthHalved;
	float rightBorderLimit = screenSize.width - imageWidthHalved;
    
    float imageHeightHalved = [_player contentSize].height * 0.5f;
    float topBorderLimit = screenSize.height - imageHeightHalved;
    float bottomBorderLimit = imageHeightHalved;
    
    CCLOG(@"Left: %f Right: %f Top: %f Bottom: %f", leftBorderLimit, rightBorderLimit, topBorderLimit, bottomBorderLimit);
    //return CGRectMake(leftBorderLimit, bottomBorderLimit, rightBorderLimit-leftBorderLimit, topBorderLimit-bottomBorderLimit);
    
    */
    CCLOG(@"__________________ width: %f height: %f", screenSize.width, screenSize.height);
        return CGRectMake(0,0,winSize.width, winSize.height);
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


-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    float sensitivity = 20;
    float acelx = acceleration.y;
    float acely = acceleration.x;
    
	/*
     To create the offset we do the following:
     1. Start with the calibration the user has set.
     2. Multiply the calibration by the sensitivity
     3. Keep in mind that the sensitivity will always be a positive value. However, when the controls are inverted we need to make this a NEGATIVE value. This is the reason we multiply the direction * -1 (remember, the direction = -1 when we're playing normal, and 1 when we're inverted).
     */
    
	float offset = calibration * sensitivity;
    float offsety = calibrationy * sensitivity;
    
    float movement = (acelx * sensitivity) + offset;
    float movementy = (acely * sensitivity) + offsety;
    
    ////////////////////////////////////////
    ////////////////////////////////////////
    // DO THE CALIBRATION FOR ACCELEROMETER
    if(calibrationFlag){
        calibration = acceleration.y;
        calibrationy = acceleration.x * -1;
        calibrationFlag = NO;
    }
    ////////////////////////////////////////
    ////////////////////////////////////////
    
	/*
     Some preliminary clarification:
     1. In my example, paddle is a sprite. However, this could be any object (like a UIImageView, etc).
     2. To make this easy to understand, let's say the paddle is 50 pixels wide and I'll hard code the bounds.
     3. cocos2d sprites use the CENTER of the object as the position point. UIKit uses the TOP LEFT corner. Change your values accordingly.
     4. In case you're wondering, \"ccp\" means CoCos2d Point. It's comparable to CGPointMake(x,y). ie: myObject.position = ccp(xPos, yPos)
     */
    
    //The IMPORTANT part of this tutorial actually lies in the first two lines of this function:
	//float acelx = -acceleration.y;
	//float movement = acelx * 40;
    
    /*
     direction = -1 for normal controls or 1 for inverted
     sensitivity can be whatever value works for your game. I usually choose values like 20 for low, 45 for med, and 70 for high.
     
     float acelx = acceleration.y * direction;
	 float movement = acelx * sensitivity;
     */
    
	//AtlasSprite *paddle = (AtlasSprite *)[spriteManager getChildByTag:kPaddle]; // raddle replaced with _player
    
    ////////////////////////////////////////
    // X AXIS
    ////////////////////////////////////////
	if ( _player.position.x > 0 && _player.position.x <= winSize.width) {
		//paddle is at neither edge of the screen so move the paddle!
		_player.position = ccp(_player.position.x + movement, _player.position.y);
	}
    
	if ( _player.position.x < 26 ) {
		//_player hit the left edge of the screen, set the left bound position with no movement.
		_player.position = ccp( 25, _player.position.y);
	}
    
	if ( _player.position.x > winSize.width - 20 ) {
		//_player hit the right edge of the screen, set the right bound position with no movement.
		_player.position = ccp( winSize.width - 20, _player.position.y);
	}
    
	if ( _player.position.x < 26 && movement > 1 ) {
		//_player is at the left edge of the screen and the device is tiled right. Move the player!
		_player.position = ccp(_player.position.x + movement, _player.position.y);
	}
    
	if ( _player.position.x >= winSize.width && movement <= 0) {
		//_player is at the right edge of the screen and the device is tiled left. Move the player!
		_player.position = ccp(_player.position.x + movement, _player.position.y);
	}
    
    ////////////////////////////////////////
    // Y AXIS
    ////////////////////////////////////////
	if ( _player.position.y > 0 && _player.position.y <= winSize.height) {
		//paddle is at neither edge of the screen so move the paddle!
		_player.position = ccp(_player.position.x, _player.position.y - movementy);
	}
    
	if ( _player.position.y < 26 ) {
		//_player hit the bottom edge of the screen, set the left bound position with no movement.
		_player.position = ccp( _player.position.x, 26);
	}
    
	if ( _player.position.y > winSize.height - 20 ) {
		//_player hit the TOP edge of the screen, set the right bound position with no movement.
		_player.position = ccp( _player.position.x, winSize.height - 20);
	}
    
	if ( _player.position.y < 26 && movementy > 1 ) {
		//_player is at the left edge of the screen and the device is tiled right. Move the player!
		_player.position = ccp(_player.position.x, _player.position.y + movementy);
	}
    
    	if ( _player.position.y > winSize.height - 20 && movementy < 0) {
    		//_player is at the right edge of the screen and the device is tiled left. Move the player!
    		_player.position = ccp(_player.position.x, _player.position.y - movementy);
    	}
    CCLOG(@"player y: %f", _player.position.y);
    
}

#define MAX_ACCEL_BIAS (0.1f)
/*-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    
    if(calibrationFlag){
        biasX = acceleration.x;
        biasY = acceleration.y;
        
        // reposition test item to center
        _player.position = cenpt;
        
        calibrationFlag = NO;
    }
    
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
	float deceleration = 0.15f;
    
	// this determines how sensitive the accelerometer reacts (higher = more sensitive)
	float sensitivity = 12.0f;
    
	// how fast the velocity can be at most
	float maxVelocity = 18.0f;
    
	// adjust velocity based on current accelerometer acceleration (adjusting for bias)
    //if (adjustForBias)
    //{
        playerVelocity.x = playerVelocity.x * deceleration + (acceleration.x-biasX) * sensitivity;
        playerVelocity.y = playerVelocity.y * deceleration + (acceleration.y-biasY) * sensitivity;
    //}
    //else
    //{
    //    playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * sensitivity;
    //    playerVelocity.y = playerVelocity.y * deceleration + acceleration.y * sensitivity;
    //}
    
    // we must limit the maximum velocity of the player sprite, in both directions (positive & negative values)
    playerVelocity.x = fmaxf(fminf(playerVelocity.x,maxVelocity),-maxVelocity);
    playerVelocity.y = fmaxf(fminf(playerVelocity.y,maxVelocity),-maxVelocity);
}*/

/*
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    
    float deltaX, deltaY = 0.0f;
    
    if (_gameOver) return;
    if(_isIntro) return;
    
    int tiltModifier = 1;

    if( [[CCDirector sharedDirector] interfaceOrientation] == UIInterfaceOrientationLandscapeRight){
        
       // [self pauseGame];
       // _accelerationX *= -1;
      //  _accelerationY *= -1;
        tiltModifier = -1;
        
        
    }else {
        tiltModifier = 1;
    }
    
    _accelerationX = 0.0f;
    //_accelerationY = 0.00459f;
    //_accelerationX = 0.0f;
    //_accelerationY = 0.0f;
   
    if(calibrationFlag){
        //_accelerationX = acceleration.x; // -0.007
        //_accelerationY = acceleration.y; // 0.00459
        //_accelerationX = -0.007f;
        //_accelerationY = 0.00459f;
        deltaX = acceleration.x;  // will be around 0.75. Movement up can then be done only from 0.75 to 1.0
                                  // min will be from 0.75 to - 0.25
        deltaY = acceleration.y;
        CCLOG(@"################ DELTA X: %f ####################", deltaX);
        
        calibrationFlag = NO;
        
    }
        
    CGPoint moveTo = _player.position;
    
    
    
    // MOVES UP AND DOWN moveTo.y
    
    
    // always keep last frames accel point
    // if > move
    // else if < move
    
    //////////////////////////
    // TILT UP
    //////////////////////////
    if(acceleration.x > _accelerationX){
        //CCLOG(@"***** TILT UP ****");
        moveTo.x =  moveTo.x + (acceleration.y * (_player.speed * upDownMultiplier)); // need faster up and down x2
        moveTo.y = moveTo.y - (acceleration.x * ( _player.speed* upDownMultiplier));  // need faster up and down x2
        // shouldMove = YES;
    }
    //////////////////////////
    // TILT DOWN
    //////////////////////////
    else if (acceleration.x < -_accelerationX) {
        // CCLOG(@"***** TILT DOWN ****");
        moveTo.x = moveTo.x + (acceleration.y * (_player.speed * upDownMultiplier)); // need faster up and down x2
        moveTo.y = moveTo.y - (acceleration.x * (_player.speed * upDownMultiplier)); // need faster up and down x2
    }
    //////////////////////////
    // TILT RIGHT
    //////////////////////////
    if(acceleration.y < -kAccelerometerMeasureY) { 
        //CCLOG(@"***** TILT RIGHT ****");
        moveTo.x = moveTo.x + (acceleration.y * (_player.speed * leftRightMultiplier));
        moveTo.y = moveTo.y - (acceleration.x * (_player.speed * leftRightMultiplier));
        // shouldMove = YES;
    }
    //////////////////////////
    // TILT LEFT
    //////////////////////////
    else if (acceleration.y > kAccelerometerMeasureY) {
        //CCLOG(@"***** TILT LEFT ****");
        moveTo.x = moveTo.x + ( acceleration.y * (_player.speed * leftRightMultiplier));
        moveTo.y = moveTo.y - (acceleration.x * (_player.speed  * leftRightMultiplier));

        // shouldMove = YES;
    } else {
        moveTo.x = moveTo.x;
        moveTo.y  = moveTo.y;
    }
    
    _player.moving = YES;
    
    [_player moveToward:moveTo];
    
    // CCLOG(@"PLAYER POSITION: %i, %i", _player.position.x, _player.position.y);
}*/

-(void) restartTapped:(id)sender{    
    [[CCDirector sharedDirector] resume];
    [m_audioManager stopAllSounds];
    //[[IAdHelper sharedInstance] moveBannerOffScreen];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene scene]]];
}

-(void) update:(ccTime)dt{
    
    if(_gameOver) return;
    //return if in intro
    if(_isIntro) return;
    
    [self determineInGameAchivemmentGameState];
    
    // PLAYER ACCELEROMETER MOVEMENT MOVED HERE VVVVV
    _player.position = [self adjustPositionByVelocity:_player.position];
    CCLOG(@"&&&&&&& PLAYER X: %f Y: %f", _player.position.x, _player.position.y);
    
    totalTime += dt;  // dont rememeber what the fuck this is for, just leave it
    _totalGameTimePlayed += dt;
    
    if(self.player.health <= 10){
        m_fTimeSpentWithUnder10Health += dt;
    }else{
        m_fTimeSpentWithUnder10Health = 0;
    }
    
    /////////////////////////////////
    // LIFE = 0 SO GAME OVER
    /////////////////////////////////
    if(self.player.health <= 0){
        // game over
        [self.player playBloodSystem];
        self.player.visible = NO;
        [_hudLayer setHp:0];
        [self endScene:kEndReasonLose];
        // XXXXX Stop all sounds... Bug
    }
    
    // boss variables if not a boss fight then update time
    if(!m_bIsBossFight){
        
        // increment time
        m_fBossBattleBeginTimer += dt;
    }
    
    if(m_fBossBattleBeginTimer >= m_fTimeToBeginBossFight){ // ready for boss fight
        
        //int randomBoss = arc4random() % 2;  // WAY TOO SLOWWWWWW
        int time = (int)totalTime;
        //CCLOG(@"&&&&&&&&&&&&&&&&&&&&&&&&&&& time %i &&&&&&&&&&&&&&&&&&&&&&&", time);
        // EVEN TIME = SHOW BOSS
        if(time % 2){
            CCLOG(@"BOSS FIGHT");
            // is boss time
            m_bIsBossFight = YES;
        
            //reset timer
            m_fBossBattleBeginTimer = 0.0f;
            [self spawnBoss];
        }
        else{
            // RESET BOSS VARS
            m_bIsBossFight = NO; // not a boss fight
            m_fTimeFightingBoss = 0.0f;
        }
    }
    
    if(m_bIsBossFight){
          m_fTimeFightingBoss += dt;
    }
    
    if(m_fTimeFightingBoss >= m_fTotalBossTime){
        m_bIsBossFight = NO;
        m_fTimeFightingBoss = 0.0f;
    }
    
    

    for(int i = 0; i < MAX_BASIC_ENEMY + MAX_BOSS_1_ENEMY; i++){
        
        ///////////////////////////////
        // COLLISION DETECTION CODE HERE
        ///////////////////////////////
        EnemyEntity *_enemy = [_basicDebugEnemies objectAtIndex:i];
        
        if(_enemy.active){
            ///////////////////////////////
            // ZOMBIE TOUCHES PLAYER
            ///////////////////////////////
            if(CGRectIntersectsRect(self.player.absoluteBoundingBox, _enemy.absoluteBoundingBox)){
                
                //[[SimpleAudioEngine sharedEngine] playEffect:@"heavyBreathing.wav"];
                // NO MORE SCORE MULTIPLIER
                _killStreak = 0;
                // TAKE AWAY LIFE
                [_hudLayer setHp:_player.health];
                //[self PlayerGotHit];
                // attack damage taken
                int dmg = [EnemyEntity getEnemyAttackDamage:_enemy.type];

                /////////////////////////////////
                // LIFE = 0 GAME OVER
                /////////////////////////////////
                if( ![self.player gotHit:dmg] ){
                    // PLAYER LOST
                    [self.player playBloodSystem];
                    self.player.visible = NO;
                    [_hudLayer setHp:0];
                    [self endScene:kEndReasonLose];
                }
                //}
                // RESET THE MULTIPLIER BECAUSE PLAYER GOT HIT
                _pointMultiplier = 1;
                
                // achievment tracking
                m_bSurvived20SecondsNoDamage = NO;

            }
            
            ///////////////////////////////
            // PLAYER SHOOTS ZOMBIE WITH A GUN
            ///////////////////////////////
            if( [self.bulletCache isPlayerBulletCollidingWithRect:_enemy.absoluteBoundingBox gunModiferType:self.player.gunModifierType] ){
                
                // WHAT IF ZOMBIE HAS LOTS OF HEALTH??
                //GET ZOMBIE HEALTH
                // (if) DEAD
                
                // Keep track of our current weapon globally, each has damage, use that here
                [_enemy gotShot:1];
                [_enemy playBloodSystem];
                
                //should extract this to method, will duplciate code for flame collision
                if(_enemy.health <= 0){
                
                    _totalZombiesKilled += 1;
                
                    //determing any multipliers
                    [self updateKillStreak:1];
                    [self setPointMultiplier];
                
                    // make thisa variable so that we can use it for printing above the dead zombie
                    int killPoints = [EnemyEntity getEnemyKillPoints:_enemy.type];
                    int killScore = (killPoints * _pointMultiplier);
                    NSString *killScoreStr = [NSString stringWithFormat:@"%02d", killScore];
                
                    _totalGameScore += killScore;
                    [_enemy showScore:killScoreStr];  
                    [_enemy setVisibleStatus:NO];
                
                    ////////////////////////////////////
                    //AMMO_PICKUP_RATE
                    if((_totalZombiesKilled % AMMO_PICKUP_RATE == 0)){ // number moved to a constant now
                        CCLOG(@"IN SPAWN GUN PICKUPS");
                        CCArray *gunPickups = [_batchNode getChildByTag:GameObjectGunPickup].children;
                        
                        if(_nextInactiveGunEnhancementPickup >= MAX_GUN_PICKUPS){
                            _nextInactiveGunEnhancementPickup = 0;
                        }
                        
                        GunEnhancment *_gunMod = [_gunEnhancementPickups objectAtIndex:_nextInactiveGunEnhancementPickup];
                        
                        _gunMod.sprite.position = _enemy.sprite.position;
                        [_gunMod makeActiveStatus:YES];
                        
                        //[[gunPickups objectAtIndex:_nextInactiveGunEnhancementPickup] setActive:YES];
                        _nextInactiveGunEnhancementPickup++;
                    }
                    
                
                    // use else if so we dont spawn one of each on top of each other
                    else if( ( (_totalZombiesKilled % MEDKIT_PICKUP_RATE) == 0) && (_totalZombiesKilled != 0) ){ // number moved to a constant now
                        
                        CCLOG(@"IN SPAWN HEALTH PICKUPS");
                        // array of sprites in the batch now - MAYBE HACKISH LOGIC
                        //CCArray *medKits = [_batchNode getChildByTag:GameObjectHealthKit].children;
                        
                        //for(int i = 0; i < MAX_HEALTH_PICKUPS; i++){
                        
                        if(_nextInactiveHealthPickup >= MAX_HEALTH_PICKUPS){
                            _nextInactiveHealthPickup = 0;
                        }

                        HealthEnhancement *_healthPack = [_healthPickups objectAtIndex:_nextInactiveHealthPickup];
                        
                        _healthPack.sprite.position = _enemy.sprite.position;
                        [_healthPack makeActiveStatus:YES];
                        //[[medKits objectAtIndex:_nextInactiveHealthPickup] setActive:YES];
                        _nextInactiveHealthPickup++;
                    }
                }
                
            }// end collision of bullet and zombie
            
            ///////////////////////////////
            // PLAYER SHOOTS ZOMBIE WITH A FLAMETHROWER
            ///////////////////////////////
            // collision with flamethrower particles
            if(self.player.gunModifierType == GunModifierFlamethrower && self.bulletCache.flameBoundingActive){
                
                if( CGRectIntersectsRect( self.bulletCache.flameThrowerBoundingSprite.boundingBox, _enemy.absoluteBoundingBox)){
                    
                    [_enemy gotShot:5];  // XXXXX kill everything
                    [_enemy playBloodSystem];
                    
                    //should extract this to method, will duplciate code for flame collision
                    if(_enemy.health <= 0){
                        
                        _totalZombiesKilled += 1;
                        
                        //determing any multipliers
                        [self updateKillStreak:1];
                        [self setPointMultiplier];
                        
                        // make thisa variable so that we can use it for printing above the dead zombie
                        int killPoints = [EnemyEntity getEnemyKillPoints:_enemy.type];
                        int killScore = (killPoints * _pointMultiplier);
                        NSString *killScoreStr = [NSString stringWithFormat:@"%02d", killScore];
                        
                        _totalGameScore += killScore;
                        [_enemy showScore:killScoreStr];
                        [_enemy setVisibleStatus:NO];
                        
                        ////////////////////////////////////
                        
                        if( ((_totalZombiesKilled % 25) == 0)){ // && (_totalZombiesKilled != 0)){
                            CCLOG(@"IN SPAWN GUN PICKUPS");
                            CCArray *gunPickups = [_batchNode getChildByTag:GameObjectGunPickup].children;
                            
                            if(_nextInactiveGunEnhancementPickup >= MAX_GUN_PICKUPS){
                                _nextInactiveGunEnhancementPickup = 0;
                            }
                            
                            GunEnhancment *_gunMod = [_gunEnhancementPickups objectAtIndex:_nextInactiveGunEnhancementPickup];
                            
                            _gunMod.sprite.position = _enemy.sprite.position;
                            //_gunMod.glow.position = _enemy.sprite.position;
                            [_gunMod makeActiveStatus:YES];
                            //[[gunPickups objectAtIndex:_nextInactiveGunEnhancementPickup] setActive:YES];
                            _nextInactiveGunEnhancementPickup++;
                            
                            // realtime set the type of modifier on the pickup box
                            //GunModifiers _gType = (arc4random() % [self getGunUnlockTypeFromAchievementCount]) + 1;
                           // CCLOG(@"Random type of pickup: %i", _gType);
                           // _gunMod.gunModifier = _gType;
                        }
                        
                        
                        // use else if so we dont spawn one of each on top of each other
                        else if( ( (_totalZombiesKilled % 30) == 0) && (_totalZombiesKilled != 0) ){
                            
                            CCLOG(@"IN SPAWN HEALTH PICKUPS");
                            // array of sprites in the batch now - MAYBE HACKISH LOGIC
                            //CCArray *medKits = [_batchNode getChildByTag:GameObjectHealthKit].children;
                            
                            //for(int i = 0; i < MAX_HEALTH_PICKUPS; i++){
                            
                            if(_nextInactiveHealthPickup >= MAX_HEALTH_PICKUPS){
                                _nextInactiveHealthPickup = 0;
                            }
                            
                            HealthEnhancement *_healthPack = [_healthPickups objectAtIndex:_nextInactiveHealthPickup];
                            
                            _healthPack.sprite.position = _enemy.sprite.position;
                            [_healthPack makeActiveStatus:YES];
                            //[[medKits objectAtIndex:_nextInactiveHealthPickup] setActive:YES];
                            _nextInactiveHealthPickup++;
                        }
                    }
                }
            }
            
            ///////////////////////////////
            // PLAYER SHOOTS ZOMBIE WITH A NUKE
            ///////////////////////////////
            if(self.player.gunModifierType == GunModifierNuke && self.bulletCache.nukeBoundingActive){
                // FUCK COLLISION JUST KILL
                //if( CGRectIntersectsRect( self.bulletCache.nukeBoundingSprite.boundingBox, _enemy.absoluteBoundingBox)){
                CCLOG(@"^^^^^^^^^^^^^^^^^^^^^ NUKE ^^^^^^^^^^^^^^^^^^^^^^^^^^");
                    [_enemy gotShot:1000];  // XXXXX kill everything
                    [_enemy playBloodSystem];
                    
                    //should extract this to method, will duplciate code for flame collision
                    if(_enemy.health <= 0){
                        
                        _totalZombiesKilled += 1;
                        
                        //determing any multipliers
                        [self updateKillStreak:1];
                        [self setPointMultiplier];
                        
                        // make thisa variable so that we can use it for printing above the dead zombie
                        int killPoints = [EnemyEntity getEnemyKillPoints:_enemy.type];
                        int killScore = (killPoints * _pointMultiplier * 20); // EXTRA BONUS FOR NUKE!
                        NSString *killScoreStr = [NSString stringWithFormat:@"%02d", killScore];
                        
                        _totalGameScore += killScore;
                        [_enemy showScore:killScoreStr];
                        [_enemy setVisibleStatus:NO];
                        
                        ////////////////////////////////////
                        
                        if( ((_totalZombiesKilled % 25) == 0)){ // && (_totalZombiesKilled != 0)){
                            CCLOG(@"IN SPAWN GUN PICKUPS");
                            CCArray *gunPickups = [_batchNode getChildByTag:GameObjectGunPickup].children;
                            
                            if(_nextInactiveGunEnhancementPickup >= MAX_GUN_PICKUPS){
                                _nextInactiveGunEnhancementPickup = 0;
                            }
                            
                            GunEnhancment *_gunMod = [_gunEnhancementPickups objectAtIndex:_nextInactiveGunEnhancementPickup];
                            
                            _gunMod.sprite.position = _enemy.sprite.position;
                            //_gunMod.glow.position = _enemy.sprite.position;
                            [_gunMod makeActiveStatus:YES];
                            //[[gunPickups objectAtIndex:_nextInactiveGunEnhancementPickup] setActive:YES];
                            _nextInactiveGunEnhancementPickup++;
                            
                            // realtime set the type of modifier on the pickup box
                            //GunModifiers _gType = (arc4random() % [self getGunUnlockTypeFromAchievementCount]) + 1;
                            // CCLOG(@"Random type of pickup: %i", _gType);
                            // _gunMod.gunModifier = _gType;
                        }
                        
                        
                        // use else if so we dont spawn one of each on top of each other
                        else if( ( (_totalZombiesKilled % 30) == 0) && (_totalZombiesKilled != 0) ){
                            
                            CCLOG(@"IN SPAWN HEALTH PICKUPS");
                            // array of sprites in the batch now - MAYBE HACKISH LOGIC
                            //CCArray *medKits = [_batchNode getChildByTag:GameObjectHealthKit].children;
                            
                            //for(int i = 0; i < MAX_HEALTH_PICKUPS; i++){
                            
                            if(_nextInactiveHealthPickup >= MAX_HEALTH_PICKUPS){
                                _nextInactiveHealthPickup = 0;
                            }
                            
                            HealthEnhancement *_healthPack = [_healthPickups objectAtIndex:_nextInactiveHealthPickup];
                            
                            _healthPack.sprite.position = _enemy.sprite.position;
                            [_healthPack makeActiveStatus:YES];
                            //[[medKits objectAtIndex:_nextInactiveHealthPickup] setActive:YES];
                            _nextInactiveHealthPickup++;
                        }
                    }
                //}
            } // END NUKE
        }
    }
    
    // MAB XXXXX FIXES THE NUKE NEEDING 2 SHOTS TO WORK BUG. HIJACK AND RESET AFTER 1
    if(self.bulletCache.nukeBoundingActive){
        self.bulletCache.nukeBoundingActive = NO;
        self.player.gunModifierType = GunModifierBasic;
    }
    // END HACK BULLSHIT
    
    // Begin HealthPickup Collision - TODO: Integratte with interface for use with other gun type pickups also
    // NSAssert([_healthPack isKindOfClass:[HealthEnhancement class]], @"HEALTHPICK NOT HEALTHPACK");
    // CCArray *medKits = [self getChildByTag:GameObjectHealthKit].children;
    for(int i = 0; i < MAX_HEALTH_PICKUPS; i++){
        if( [[_healthPickups objectAtIndex:i] active] ){
            HealthEnhancement *_collidedMedPack = [_healthPickups objectAtIndex:i];
            if( CGRectIntersectsRect(self.player.boundingBox, _collidedMedPack.sprite.boundingBox) ){
                
                // player collided with med pack
                
                //set inactive in batch
                [_collidedMedPack setActive:NO];
                
                // call player add health function
                
                [self.player addHealth:[_collidedMedPack getHealthAmount]];
                [_hudLayer setHp:_player.health];
                // PLAY PLAYERS HEALTH PARTICLE SYSTEM
                // XXXXX Now works, may be too big.
                CCParticleSystemQuad *medKitPickup = [CCParticleSystemQuad particleWithFile:@"healthPickup3.plist"];
                
                medKitPickup.duration = 0.4f;
                medKitPickup.scale = 0.4f;
                medKitPickup.position = self.player.position;
                [self addChild:medKitPickup z:170];
                
                //reset medpack
                [_collidedMedPack reset];
                
                // achievemnet tracking
                m_iMedKitUsageCount += 1;
                m_bFirstMedKit = YES;
            }
        }
    }
    
    for(int i = 0; i < MAX_GUN_PICKUPS; i++){
        if( [[_gunEnhancementPickups objectAtIndex:i] active] ){
            GunEnhancment *_collidedGunUpgrade = [_gunEnhancementPickups objectAtIndex:i];
            if( CGRectIntersectsRect(self.player.boundingBox, _collidedGunUpgrade.sprite.boundingBox)){
                CCLOG(@"Collision with Ammo Box");
                
                [_collidedGunUpgrade setActive:NO];
                
                self.player.gunModifierType = _collidedGunUpgrade.gunModifier;
                
              //  [self.player setGunModifierType:_collidedGunUpgrade.gunModifier];
                
                //play reload sound here
                [[SimpleAudioEngine sharedEngine] playEffect:@"reload.wav"];
                
                //play particle system maynbe or show text
                
                [_collidedGunUpgrade reset];
                
                // reset bullet count on player
                [self.player resetBulletTracker];
                
                //achievment tracking
                m_bFirstAmmoBox = YES;
                
                [self showGunPickupLabel:[GunModifierComponent getGunModifierComponentName:self.player.gunModifierType]];
            }
        }
    }
        
    // HUD UPDATES
    [_hudLayer setScore:_totalGameScore];
    [_hudLayer setGunLabel:[GunModifierComponent getGunModifierComponentName:self.player.gunModifierType]];
    
    [self.bulletCache updateFlameBoundingSpriteTimer:dt];
    
    if(self.player.health <= 0){
        self.player.health = 0;
        self.player.visible = NO;
    }
    
    if( timeSinceLastSpawn >= spawnEnemy){
        //       // CCLOG(@"Spawn Zombie");
        timeSinceLastSpawn = 0;
        
        // play a sound...
        int randomGrowl = arc4random() % 5;
        NSString *growFileName = [NSString stringWithFormat:@"zombieGrowl%i.mp3", randomGrowl];
        [[SimpleAudioEngine sharedEngine] playEffect:growFileName];
        
        
       /* if((float)_totalGameTimePlayed % 15 <= 0){

        }*/
        
        // THIS IF THEN ELSE WILL EASE THE PLAYER INTO THE ZOMBIE RESPAWNING
        if(_totalGameTimePlayed > STARTUP_EASY_PLAY_TIME){                // CONSTANT SO WE CAN CHANGE DURING GAME TESTING
            
            // GAME ON!
             //_respawnInterval = [self CalculateRespawnRate];  // THIS ADDS DYNAMIC RESPAWNING
            _respawnInterval = [self TimedRespawnRate];  // THIS ADDS DYNAMIC RESPAWNING XXXXX v1.1.1 new respawn code
        }
        else{
            // ease the player into the game
            _respawnInterval = 0.85;
        }

        if(m_bIsBossFight)
            _respawnInterval = 1.5f;
        
        //_respawnInterval = [self CalculateRespawnRate];  // THIS ADDS DYNAMIC RESPAWNING
        [self unschedule:@selector(spawnEnemy)];
        [self schedule:@selector(spawnEnemy) interval:_respawnInterval];
        
        
        //[self CalculateRespawnRate];
    }
    else{
        timeSinceLastSpawn += dt;
    }
}

// XXXXX 1.1.1 Respawn fix to make even out...
-(float)TimedRespawnRate{
    int val = arc4random() % 100; // returns [0,100)
    float respawnRate;
    if(val < 10){
        respawnRate = 1.0f;
    }
    else if(val < 25){
        respawnRate = 0.8f;
    }
    else if(val < 40){
        respawnRate = 0.7f;
    }
    else if(val < 60){
        respawnRate = 0.6f;
    }
    else if(val < 80){
        respawnRate = 0.5f;
    }
    else if(val < 98){
        respawnRate = 0.4f;
    }
    else{
        respawnRate = 0.3f;
    }
    
    if(m_bIsBossFight){
        respawnRate = 1.5f;
    }
    
    CCLOG(@"------------- RESPAWN RATE: %f ---------------------", respawnRate);
    return respawnRate;

}

-(float)CalculateRespawnRate{
    // XXXXX NOT USED v1.1.1 and beyond
    int val = arc4random() % 100; // returns [0,100)
    float respawnRate;
    if (val < 50){                       // 50% of the time
        respawnRate = CCRANDOM_0_1() + .2f;
        //respawnRate = [self RandomFloat:0.5 :1.2];
    }
    else if (val < 70){                  // 20% of the time
        respawnRate = CCRANDOM_0_1() + .1f;
        //respawnRate = [self RandomFloat:0.65 :1.3];
    }
    else if (val < 95){                  // 25% of the time
        //respawnRate = [self RandomFloat:0.15 :0.3];
        respawnRate = 0.3f;
    }
    else{                               // 5% of the time
        respawnRate = 0.2f;
        //respawnRate = [self RandomFloat:0.2 :0.4];
    }
    
    CCLOG(@"------------- RESPAWN RATE: %f ---------------------", respawnRate);
    
    if(m_bIsBossFight){
        
        respawnRate = 1.0f;
    }
    
    return respawnRate;
}

// create a float between a min and max value
-(float)RandomFloat:(float)minVal :(float)maxVal{

    float diff = minVal - maxVal;
    return fabsf((((float)(arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + minVal);
}

-(void) spawnEnemy{
    /*int randomGrowl = arc4random() % 5;
     NSString *growFileName = [NSString stringWithFormat:@"zombieGrowl%i.mp3", randomGrowl];
     
     //[[SimpleAudioEngine sharedEngine] playEffect:@"zombieGrowl2.mp3"];
     [[SimpleAudioEngine sharedEngine] playEffect:growFileName];
     */
    // XXXXX MAKE THE ENEMY SIZE RAMP UP AND DOWN
    int enemySize = 25;
    
    // Determine where to spawn the target along the Y axis
    //CGSize winSize = [[CCDirector sharedDirector] winSize]; //Get the screensize
    
    int minX = enemySize;
    int maxX = winSize.width - enemySize;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // count freq;
    int _loopCount = 0;
    
    //int _numberOfEnemyToSpawn = [EnemyEntity getEnemySpawnAmountPerType:enemyType];
    
    // XXXXXX Make this variable increase and decrease (think sin curve)
    //int _randomNumberOfEnemyToSpawn = arc4random() % 4;
    
    int _randomNumberOfEnemyToSpawn = 1;
    
    // will need to switch on types
    for(int i = 0; i < _basicDebugEnemies.count - MAX_BOSS_1_ENEMY; i++){
        
        EnemyTypes _spawnType = BASIC_ZOMBIE;
        CGPoint randomSpawn;
        EnemyEntity *enemy = [_basicDebugEnemies objectAtIndex:i];
        
        // RANDOMIZE TYPE HERE
        //  EnemyTypes _spawnType = [self getEnemySpawnType];
        
        if(![enemy active]){
            
            //if(![enemy active] && ([enemy type] == _spawnType) ){
            _randomNumberOfEnemyToSpawn++;
            // Determine where to spawn the target along the Y axis
            int minY = enemySize;
            int maxY = winSize.height - enemySize;
            int rangeY = maxY - minY;
            int actualY = (arc4random() % rangeY) + minY;
            
            int randomDirection = (arc4random() % 4) + 1;
            
            switch(randomDirection){
                case 1:
                    // TOP
                    randomSpawn = ccp(actualX, (winSize.height - enemySize));
                    break;
                    
                case 2:
                    // BOTTOM
                    randomSpawn = ccp(actualX, (0 - enemySize));
                    break;
                    
                case 3:
                    // LEFT
                    randomSpawn = ccp(0 + (enemySize), actualY);
                    break;
                    
                case 4:
                    // RIGHT
                    randomSpawn = ccp( winSize.width + (enemySize) , actualY);
                    break;
                    
                default:
                    break;
            }
            
            //randomSpawn.x = CCRANDOM_0_1() * winSize.width;
            //randomSpawn.y = CCRANDOM_0_1() * winSize.height;
            [enemy setPosition:randomSpawn];
            [enemy setVisibleStatus:YES];
            CCLOG(@"** ENEMY HEALTH WHEN SPAWNED: %i", enemy.health);
            _loopCount++;
            CCLOG(@"_loopCount: %i", _loopCount);
            
            // stop when we reach our desired amount of enemies to spawn
            // if(_loopCount > _randomNumberOfEnemyToSpawn)
            break;
        }
    }
}

-(void) endScene:(EndReson)endReason{
    
    if(_gameOver) return;
    _gameOver = true;
    
   // [[IAdHelper sharedInstance] createAdView];
  //  [navController.view addSubview:[[IAdHelper sharedInstance]bannerView]];
    
    
   // UINavigationController *navController = [[CCDirector sharedDirector] navigationController];
    //[navController.view addSubview:[[IAdHelper sharedInstance]bannerView]];
    /*
     if( ![[InAppDeadstormHelper sharedHelper] productPurchased:kDeadStormRemoveAdsIdentifier] ){
        [[IAdHelper sharedInstance] moveBannerOnScreen];
    }
     */
    self.player.visible = NO;
    
    ////////////////////
    // TIME FORMATTING
    ///////////////////
    int tempTime = _totalGameTimePlayed;
    int days = tempTime / (60 * 60 * 24);
    tempTime -= days * (60 * 60 * 24);
    
    int hours = (tempTime / (60 * 60));
    tempTime -= hours * (60 * 60);
    int minutes = (tempTime / 60);
    
    tempTime -= minutes * 60;
    int seconds = tempTime;
    
    NSString *killCount = [NSString stringWithFormat:@"kills: %i" , _totalZombiesKilled];
    
    //NSString *gameTime = [NSString stringWithFormat:@"Time: %f", _totalGameTimePlayed];
    NSString *gameTime = [NSString stringWithFormat:@"time played: %02i:%02i:%02i", hours, minutes, seconds];
    
    NSString *shotsFired = [NSString stringWithFormat:@"shots fired: %i", _totalShotsFired];
    NSString *totalScore = [NSString stringWithFormat:@"score: %i", _totalGameScore];
    
    CCLabelBMFont *_gameOverLabel = [CCLabelBMFont labelWithString:@"game over" fntFile:@"planecrash_55.fnt"];
    
    // PULL OUT FONT SIZE FOR NON RETINA AS A VAR IN MAIN???? DEPENDS HOW IT RENDERS
    //CCLabelTTF *_killCountLabel = [CCLabelTTF labelWithString:killCount fontName:@"Times New Roman" fontSize:20];
    CCLabelBMFont *_killCountLabel = [CCLabelBMFont labelWithString:killCount fntFile:@"planecrash_24_black.fnt"];
    
    //CCLabelTTF *_gameTimeLabel = [CCLabelTTF labelWithString:gameTime fontName:@"Times New Roman" fontSize:20];
    CCLabelBMFont *_gameTimeLabel = [CCLabelBMFont labelWithString:gameTime fntFile:@"planecrash_24_black.fnt"];
    
    //CCLabelTTF *_shotsFiredLabel = [CCLabelTTF labelWithString:shotsFired fontName:@"Times New Roman" fontSize:20];
    CCLabelBMFont *_shotsFiredLabel = [CCLabelBMFont labelWithString:shotsFired fntFile:@"planecrash_24_black.fnt"];
        
    //CCLabelTTF *_totalScoreLabel = [CCLabelTTF labelWithString:totalScore fontName:@"Times New Roman" fontSize:20];
    CCLabelBMFont *_totalScoreLabel = [CCLabelBMFont labelWithString:totalScore fntFile:@"planecrash_24_black.fnt"];
    
    _killCountLabel.color = ccc3(0,0,0); // black
    _gameTimeLabel.color = ccc3(0,0,0);
    _shotsFiredLabel.color = ccc3(0,0,0);
    _totalScoreLabel.color = ccc3(0,0,0);
    
    _gameOverLabel.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.35) ));
    
    _killCountLabel.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.45) ));
    _gameTimeLabel.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.5) ));
    _shotsFiredLabel.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.55) ));
    _totalScoreLabel.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.6) ));
    
    [self addChild: _gameOverLabel z:200];
    
    [self addChild:_killCountLabel z:200];
    [self addChild:_gameTimeLabel z:200];
    [self addChild:_shotsFiredLabel z:200];
    [self addChild:_totalScoreLabel z:200];
    
    //////////////////////////
    // SAVE GAME DATA TO DEVICE
    // AND DISPLAY ON SCREEN
    ///////////////////////////
    [self SaveGameStats];
    
    [[CCDirector sharedDirector] pause];
    
    
    CCLayerColor *_endScreenLayer = [CCLayerColor layerWithColor:ccc4(1,1,1,1) width:winSize.width height:winSize.height];
    
    _endScreenLayer.position = CGPointZero;
    [self addChild:_endScreenLayer];
    
    CCSprite *_endGameBackground = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
    [_endGameBackground setPosition:CGPointMake(winSize.width * 0.5f, winSize.height*0.5)];
    //[_pauseMenuBackground addChild:m_introSpriteBackground z:6];
    [self addChild:_endGameBackground z:199];
    
    // IMAGE BUTTONS
    //CCMenuItemImage *quit = [CCMenuItemImage itemWithNormalImage:@"Quit_Button_Small.png" selectedImage:@"Quit_Button_Small_over.png" disabledImage:@"Quit_Button_Small.png" target:self selector:@selector(quitGame:)];
    
    
    CCMenuItemImage *tweet = [CCMenuItemImage itemWithNormalImage:@"PostToTwitter.png" selectedImage:@"PostToTwitter_over.png" target:self selector:@selector(tweetScore:)];
    //CCMenuItemImage *store = [CCMenuItemImage itemWithNormalImage:@"store-button-small.png" selectedImage:@"store-button-small-over.png" target:self selector:@selector(store:)];
    
    CCMenuItemImage *restart = [CCMenuItemImage itemWithNormalImage:@"restart-button-small.png" selectedImage:@"restart-button-small_over.png" disabledImage:@"restart-button-small.png" target:self selector:@selector(restartTapped:)];
    
    // ADD LABELS FOR SCORE AND MESSAGE
    
    //restart.fontSize = 32;
    //quit.fontSize = 32;
    
    CCMenu *endMenu = [CCMenu menuWithItems: tweet, restart, nil];
    endMenu.position = ccp( (winSize.width * 0.5f), (winSize.height *0.5f) - (winSize.height * 0.25f) );
    [endMenu alignItemsHorizontallyWithPadding:20];
    //[endMenu alignItemsVerticallyWithPadding:5];
    
    [self addChild:endMenu z:201];
    
    CCMenuItemImage *leaderboards = [CCMenuItemImage itemWithNormalImage:@"back_button2.png" selectedImage:@"back_button2_over.png" disabledImage:@"back_button2.png" target:self selector:@selector(quitGame:)];
    CCMenu *gameCenterOptions = [CCMenu menuWithItems:leaderboards, nil];
    //gameCenterOptions.position = ccp(winSize.width * 0.90f, winSize.height -75);
    
    if(winSize.width == 568){ //iPhone 5 resolution
    gameCenterOptions.position = ccp(winSize.width * 0.84f, winSize.height -75);
    }
    else{ // iPhone 4s and whatever
        gameCenterOptions.position = ccp(winSize.width * 0.90f, winSize.height -75);
    }

    // TO DO MAB XXXXX ADD STORE BUTTON
    
    [gameCenterOptions alignItemsHorizontally];
    
    [self addChild:gameCenterOptions z:201];
    
//    CCMenuItemImage *m_leaderboard = [CCMenuItemImage itemWithNormalImage:@"leaderboardsButton.png" selectedImage:@"leaderboardsButton.png" disabledImage:@"leaderboardsButton.png" target:self selector:@selector(leaderboards)];
//    
//    CCMenuItemImage *m_achievements = [CCMenuItemImage itemWithNormalImage:@"achievementsButton.png" selectedImage:@"achievementsButton.png" disabledImage:@"achievementsButton.png" target:self selector:@selector(showAchievements)];
//    
//    CCMenu *m_menu = [CCMenu menuWithItems:m_leaderboard, m_achievements, nil];
//    [m_menu alignItemsHorizontallyWithPadding:5];
//    [m_menu setPosition:ccp(winSize.width/2, winSize.height/2 - 80)];
//    [self addChild:m_menu z:206];
    
    
    
    // Submit score to game center
    CCLOG(@"Submitting Score to Game Center");
    [[GCHelper sharedInstance] reportScore:kLeaderboardHighScore score:_totalGameScore];
    [[GCHelper sharedInstance] reportScore:kLeaderboardKills score:_totalZombiesKilled];
}

-(void) showAchievements{
    CCLOG(@"Show Achievements");
    
    //  [gkHelper showAchievements];
    
    [[GCHelper sharedInstance] showAchievements];
    
    //    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    //
    //    if(achievements != NULL){
    //        achievements.achievementDelegate = self;
    //        [delegate.viewController presentModalViewController:achievements animated:YES];
    //    }
    
}

-(void)leaderboards{
    // allow for muiltpile types of leaderboard querying
    [[GCHelper sharedInstance] showLeaderboard];
}

-(void) SaveGameStats{
    ///////////////////////////////////////////////////////////////////////////
    // SAVE GAME DATA TO DEVICE
    ///////////////////////////////////////////////////////////////////////////
    // FIRST RETRIEVE GAME DATA FROM THE DEVICE
    ///////////////////////////////////////////////////////////////////////////
    int tempTotalShotsFired = 0;
    int tempTotalKillCount = 0;
    int tempTotalScore = 0;
    float tempTotalGameTime = 0.0f;
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TotalShotsFired"] == nil){
        tempTotalShotsFired = 0;
    }
    else{
        tempTotalShotsFired = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalShotsFired"];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TotalKillCount"] == nil){
        tempTotalKillCount = 0;
    }
    else{
        tempTotalKillCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalKillCount"];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TotalScore"] == nil){
        tempTotalScore = 0;
    }
    else{
        tempTotalScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalScore"];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TotalGameTime"] == nil){
        tempTotalGameTime = 0;
    }
    else{
        tempTotalGameTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalGameTime"];
    }
    
    NSMutableArray *highScoreArray;// = [[NSMutableArray alloc] initWithCapacity:11];
    
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"HighScores"] == nil){
        // first time playing?
        
        highScoreArray  = [[NSMutableArray alloc] initWithCapacity:11];
        
        NSLog(@"NO PREVIOUS HIGH SCORES... CREATE NEW ONES");
        highScoreArray= [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil];
    }
    else{
        
        // seems to be problem with the NSArray begin retunred while being directly set to an instance
        // of NSMutableArray
        NSArray* aHighScoreArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"HighScores"];
        highScoreArray = [aHighScoreArray mutableCopy];
        
        if(_totalGameScore > [[aHighScoreArray objectAtIndex:0] integerValue] ){
            m_bIsHighScore = YES;
        }
    }
    

    // ADD CURRENT SCORE TO THE LAST INDEX...
    if(highScoreArray != nil || [highScoreArray count] != 0){
        [highScoreArray insertObject:[NSNumber numberWithInt:_totalGameScore] atIndex:11];
        
    }
    
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    // XXXXX BUG HERE 
    NSMutableArray *newHighScoreArray = [highScoreArray sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    NSLog(@"High Score Array: %@", highScoreArray);

    NSLog(@"Sorted High Score Array: %@", newHighScoreArray);
    
    //if(m_bIsHighScore){
        CCSprite* highScoreImage = [CCSprite spriteWithFile:@"highScoreButton.png"];
        //highScoreImage.tag = 3;
        //highScoreImage.position = ccp(110, winSize.height - 80);
    
        if(winSize.width == 568){ //iPhone 5 resolution
            highScoreImage.position = ccp(154, winSize.height - 80);
        }
        else{ // iPhone 4s and whatever
            highScoreImage.position = ccp(110, winSize.height - 80);
        }
        [self addChild: highScoreImage z:200];
    //}
    
    
    
    ////////////////////////////////////////////////////////
    // APPEND LAST GAME DATA TO THESE VALUES FROM THE DEVICE
    ////////////////////////////////////////////////////////
    tempTotalShotsFired += _totalShotsFired;
    tempTotalKillCount += _totalZombiesKilled;
    tempTotalScore += _totalGameScore;
    tempTotalGameTime += _totalGameTimePlayed;
    
    ////////////////////////////////////////////////////////
    // SAVE TO DEVICE AGAIN
    ////////////////////////////////////////////////////////
    [[NSUserDefaults standardUserDefaults] setInteger:tempTotalShotsFired forKey:@"TotalShotsFired"];
    [[NSUserDefaults standardUserDefaults] setInteger:tempTotalKillCount forKey:@"TotalKillCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:tempTotalScore forKey:@"TotalScore"];
    [[NSUserDefaults standardUserDefaults] setFloat:tempTotalGameTime forKey:@"TotalGameTime"];
    // save high scores array
    [[NSUserDefaults standardUserDefaults] setObject:newHighScoreArray forKey:@"HighScores"];
    
    // Syncronize to device
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ///////////////////////////////////////////////////////////////////////////
    // END SAVING GAME DATA TO DEVICE
    ///////////////////////////////////////////////////////////////////////////
    
    // Format the time nicely one more time
    int tempTime2 = tempTotalGameTime;
    int days2 = tempTime2 / (60 * 60 * 24);
    tempTime2 -= days2 * (60 * 60 * 24);
    
    int hours2 = (tempTime2 / (60 * 60));
    tempTime2 -= hours2 * (60 * 60);
    int minutes2 = (tempTime2 / 60);
    
    tempTime2 -= minutes2 * 60;
    int seconds2 = tempTime2;
    
    /*NSString *saveInfo = [NSString stringWithFormat:@"Shots: %i || Kills: %i || Score: %i || Total Time: %02i:%02i:%02i", tempTotalShotsFired, tempTotalKillCount, tempTotalScore, hours2, minutes2, seconds2];
    CCLabelTTF *_savedData = [CCLabelTTF labelWithString:saveInfo fontName:@"Times New Roman" fontSize:10];
    
    //CCLabelBMFont *_bmfSavedData = [CCLabelBMFont labelWithString:saveInfo fntFile:@"planecrash_14_black-hd.fnt"];
    //CCLabelAtlas *_atlSavedData = [CCLabelAtlas labelWithString:saveInfo fntFile:@"planecrash_14_black.fnt"];
    _savedData.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.65) ));
    _savedData.color = ccc3(0,0,0);
    [self addChild:_savedData z:201];*/
    
    if(_totalZombiesKilled == 0) {
        m_bDiedWithNoKils = YES;
    }
    m_bFirstGameFinished = YES;
    
    [self determineOverallAchievementGameStateWithTotalKills:tempTotalKillCount timePlayed:tempTime2 withPoints:tempTotalScore];
    

}


- (CGPoint) getPlayerLocation{
    
    return self.player.position;
}

-(void)beginGame:(id)sender{
    
    // method to be sent as a selector when the game initially loads
    // this will remove the pop up instruction screen and begin the game officially
    [self removeChild:_introSplashLayer cleanup:YES];
    
    _isIntro = NO;
    //[[CCDirector sharedDirector] resume];
    
    // PLAY THE GAME SONG
    SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
    
    [sae playBackgroundMusic:@"DS_Song.mp3" loop:YES];   // added loop
    sae.backgroundMusicVolume = 0.3f;                    // adjust sound volume
    /*********************************/
    
    ////////////////////////////////////////////////
    ////////////////////////////////////////////////
    int iAdCounter = 0;
    // RETREIVE FROM DEVICE
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"iAdGameCounter"] == nil){
        iAdCounter = 1;
    }
    else{
        iAdCounter = [[NSUserDefaults standardUserDefaults] integerForKey:@"iAdGameCounter"];
        // HOW ANNOYING DO WE WANT TO BE?
        if(iAdCounter < 6){
            iAdCounter++;
            //CCLOG("iAD COUNTER: %i", iAdCounter);
        }
        else{
            iAdCounter = 1;
        }
    }
    // SAVE TO DEVICE
    [[NSUserDefaults standardUserDefaults] setInteger:iAdCounter forKey:@"iAdGameCounter"];
    ////////////////////////////////////////////////
    ////////////////////////////////////////////////
    // ADDED ANNOYING AD MAB XXXXX
    int randomAd = arc4random() % 6;
        
    CCLOG(@"&&&&&&&&&&&&&&&& RANDOM AD %i", randomAd);
    // OK DON'T ANNOY THE PLAYER EVERY GAME
    /*
    if(randomAd == 2 || randomAd == 4){
    //if(iAdCounter == 2){
        if( ![[InAppDeadstormHelper sharedHelper] productPurchased:kDeadStormRemoveAdsIdentifier] ){
            [[IAdHelper sharedInstance] moveBannerOnScreen];
        }
    }
    */
    /*********************************/
    
    [self schedule:@selector(spawnEnemy) interval:_respawnInterval];
    
}

-(void)resumeGame:(id)sender{
    
    
    [self removeChild:_pauseMenu cleanup:YES];
    [self removeChild:_pauseMenuBackground cleanup:YES];
    
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] startAnimation];
    
    _isPaused = NO;
    
    //[[IAdHelper sharedInstance] moveBannerOffScreen];
   // [self unPauseAllEnemies];
}

-(void)quitGame:(id)sender{
    
    [[CCDirector sharedDirector] resume];
    [m_audioManager stopAllSounds];
    //[[IAdHelper sharedInstance] moveBannerOffScreen];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[MenuScene scene]]];
}

-(void) pauseGame{
      [[CCDirector sharedDirector] pause];
    if(!_isPaused){
        
        //get out singleton
        
        _isPaused = YES;
        
       // if( ![[CCDirector sharedDirector] isPaused] ){
          
        
      //  }
        
        //[self pauseAllEnemies];
        
//        UINavigationController *navController = [[CCDirector sharedDirector] navigationController];
//        [navController.view addSubview:[[IAdHelper sharedInstance]bannerView]];
        
        /*
         if( ![[InAppDeadstormHelper sharedHelper] productPurchased:kDeadStormRemoveAdsIdentifier] ){
            [[IAdHelper sharedInstance] moveBannerOnScreen];
        }
        */
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        _pauseMenuBackground = [CCLayerColor layerWithColor:ccc4(1,1,1,1) width:s.width height:s.height];
        _pauseMenuBackground.position = CGPointZero;
        CCSprite *m_introSpriteBackground = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        [m_introSpriteBackground setPosition:CGPointMake(winSize.width * 0.5f, winSize.height*0.5)];
        [_pauseMenuBackground addChild:m_introSpriteBackground z:6];
        [self addChild:_pauseMenuBackground z:500]; // increase z index to fix bug
        
        CCMenuItemImage *resume = [CCMenuItemImage itemWithNormalImage:@"Resume_Button.png" selectedImage:@"Resume_Button_over.png" disabledImage:@"Resume_Button.png" target:self selector:@selector(resumeGame:)];
        CCMenuItemImage *quit = [CCMenuItemImage itemWithNormalImage:@"Quit_Button.png" selectedImage:@"Quit_Button_over.png" disabledImage:@"Quit_Button.png" target:self selector:@selector(quitGame:)];
        CCMenuItemImage *restart = [CCMenuItemImage itemWithNormalImage:@"Restart_Button.png" selectedImage:@"Restart_Button_over.png" disabledImage:@"Restart_Button.png" target:self selector:@selector(restartTapped:)];
        // TO DO MAB XXXXX ADD STORE BUTTON
    
        _pauseMenu = [CCMenu menuWithItems:resume, restart, quit, nil ];
        _pauseMenu.position = ccp(s.width / 2, s.height / 2);
        [_pauseMenu alignItemsVertically];
        
        [self addChild:_pauseMenu z:501]; // increase z index to fix home button click (resume bug of stuff not showing up)
        
        //m.isPaused = m_isPaused;
        
       // [[CCDirector sharedDirector] stopAnimation];
    }
}

-(void) tweetScore:(id)sender{
    
    DataSystemsManager *m_dataManager = [DataSystemsManager getDataSystemsManager];
    //[m_dataManager tweetMessage];
    
    // format message ADDED LINK TO BE THE AFFILIATE LINK
    NSString *_msg = [NSString stringWithFormat:@"I scored %i in #DeadStorm #iOS and killed %i zombies. @DeadstormGame - http://tinyurl.com/deadstorm", _totalGameScore, _totalZombiesKilled];
    [m_dataManager tweetMessage:_msg];
    
}

-(void) setPointMultiplier{
    
    bool changed = false;
    
    // CURRENT: 23 Achievements available to unlock
    //int _achievementCount = [GameState sharedInstance].achiementCount;
    int _achievementCount = 100;  // we don't use game center anymore so commented out that info and you can unlock up to 10 no matter what 10/25/2012 MAB
    
    if(_killStreak == 10){
        _pointMultiplier = 2;
        changed = true;
        m_bFirstMultiplier = YES;
        // DRAW 2X Multiplier
    }else if(_killStreak == 15 && _achievementCount > 1){
        _pointMultiplier = 3;
        changed = true;
    }else if(_killStreak == 20 && _achievementCount > 2){
        changed = true;
        _pointMultiplier = 4;
    }else if(_killStreak == 30 && _achievementCount > 4){
        changed = true;
        _pointMultiplier = 5;
    }else if(_killStreak == 40 && _achievementCount > 6){
        changed = true;
        _pointMultiplier = 6;
    }else if(_killStreak == 45 && _achievementCount > 8){
        changed = true;
        _pointMultiplier = 7;
    }else if(_killStreak == 50 && _achievementCount > 10){
        changed = true;
        _pointMultiplier = 8;
    }else if(_killStreak == 55 && _achievementCount > 12){
        changed = true;
        _pointMultiplier = 9;
    }else if(_killStreak == 60 && _achievementCount > 15){
        changed = true;
        _pointMultiplier = 10;
    }
    
    // DISPLAY THE MULTIPLIER ON THE SCREEN
    if(changed && _pointMultiplier > 1){
        //
        NSString *multiplierFilename = [NSString stringWithFormat:@"%dxMultiplier.png",_pointMultiplier];
        CCSprite* multiplierSprite = [CCSprite spriteWithSpriteFrameName:multiplierFilename];
        multiplierSprite.tag = 5;
        multiplierSprite.anchorPoint = CGPointMake(0, 0);
        
        //CCSprite _multiplierSprite =
        [self addChild: multiplierSprite z:121];
        
        [multiplierSprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.3], [CCCallFuncN actionWithTarget:self selector:@selector(removeLabel:)], nil]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"squish1.mp3"];
        
      
        changed = false;
    }
}

// remove the label from memory
-(void) removeLabel: (id) sender
{
    [self removeChild:sender cleanup:YES];
    
}


-(int) updateKillStreak:(int)amount{
    
    if(amount > 0){
        
        _killStreak += amount;
        
    }else{
        _killStreak = 0;
    }
    
    return _killStreak;
}

#define MAX_MULTIPLIER 10
#define MIN_MULTIPLIER 2
-(void) initSpriteMultipliers{
    
    //    _spriteMultipliers = [[CCArray alloc] initWithCapacity:MAX_MULTIPLIER];
    //    for(int i = MIN_MULTIPLIER; i < MAX_MULTIPLIER + 1; i++){
    //
    //        NSString *multiplierFilename = [NSString stringWithFormat:@"%dxMultiplier.png",i];
    //        CCSprite* multiplierSprite = [CCSprite spriteWithSpriteFrameName:multiplierFilename];
    //        multiplierSprite.tag = 5;
    //        multiplierSprite.anchorPoint = CGPointMake(0, 0);
    //        //[self addChild: multiplierSprite z:121];
    //
    //    }
}

-(EnemyTypes) getEnemySpawnType{
    
    int random = arc4random() % 4;
    
    EnemyTypes typeToReturn;
    
    if(random == 0){
        typeToReturn = BASIC_ZOMBIE;
    }else if(random == 1){
        typeToReturn = BASIC_ZOMBIE_2;
    }else if(random == 2){
        typeToReturn = BASIC_ZOMBIE_3;
    }else if(random == 3){
        typeToReturn = SLOW_ZOMBIE;
    }else{
        typeToReturn = BASIC_ZOMBIE;
    }

    return typeToReturn;
}

-(int) getGunUnlockTypeFromAchievementCount{
    
    // based on the number of achievements here
    // we will retunr in integrer that will represent the hights unlock -1
    // we use -1 because we do not want the 0 item (basic) to be a pickup
    // so after we randomize we increase it by +1 regardess
    
    // 2 = 0, 1, 2
    
    //return 4;
    CCLOG(@"getGunUnlockTypeFromAchievemntCount: %f", _totalGameTimePlayed);
    
    if(_totalGameTimePlayed >= 20.0f &&_totalGameTimePlayed <= 30.0f){
     
        CCLOG(@"hollow unlocked");
        // double
        [self showGunUnlockLabel:@"hollow point unlocked"];
        return 2;
        
    }else if(_totalGameTimePlayed >= 45.0f && _totalGameTimePlayed <= 60.0f){
        
        CCLOG(@"scatter shot unlocked");
        [self showGunUnlockLabel:@"scatter shot unlocked"];
        // triple
        return 3;
        
    }else if(_totalGameTimePlayed >= 90.0f && _totalGameTimePlayed <= 120.0f){
        
        CCLOG(@"flame thrower unlocked");
        [self showGunUnlockLabel:@"flamethrower unlocked"];
        //flame
        return 4;
    }
    
    return 1;
}

-(void) determineInGameAchivemmentGameState{
    
    // first kill
    if(_totalZombiesKilled >= 1 && _totalZombiesKilled <= 20){
       
        
        if( ![GameState sharedInstance].firstKill_g ){
             CCLOG(@"FirstKill Achievement");
            [GameState sharedInstance].firstKill_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kFirstKill_g percentComplete:100.0];
            
        }
    }else if(_totalZombiesKilled >= 200 && _totalZombiesKilled < 500){
        
        if( ![GameState sharedInstance].killed200InGame_g ){
            CCLOG(@"Killed 200 Achievement");
            [GameState sharedInstance].killed200InGame_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kKilled200InGame_g percentComplete:100.0];
        }
        
    }else if(_totalZombiesKilled >= 500 && _totalZombiesKilled < 1000){

        if( ![GameState sharedInstance].killed500InGame_g ){
            CCLOG(@"Killed 500 Achievement");
            [GameState sharedInstance].killed500InGame_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kKilled500InGame_g percentComplete:100.0];
        }
    }
    
    // First Med Kit Pickup
    if(m_bFirstMedKit){
        if( ![GameState sharedInstance].pickupFirstMedKit_g ){
            CCLOG(@"First Medkit pickup Achievement");
            [GameState sharedInstance].pickupFirstMedKit_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kPickupFirstMedKit_g percentComplete:100.0];
        }
    }
    
    // First Ammo Box
    if(m_bFirstAmmoBox){
        if( ![GameState sharedInstance].pickUpFirstAmmoBox_g ){
            CCLOG(@"First ammo pickup Achievement");
            [GameState sharedInstance].pickUpFirstAmmoBox_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kPickUpFirstAmmoBox_g percentComplete:100.0];
        }

    }
    
    // Kill 200 NO MED KIT
    if( _totalZombiesKilled >= 200 && !m_bFirstMedKit){
        
        if( ![GameState sharedInstance].killed200InGameNoMedkit_g ){
            CCLOG(@"Killed 200 No Medkit pickup Achievement");
            [GameState sharedInstance].killed200InGameNoMedkit_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kKilled200InGameNoMedkit_g percentComplete:100.0];
        }
    }
    
    // 50,000 Point Achivement
    if(_totalGameScore >= 50000 && _totalGameScore < 100000){
        if( ![GameState sharedInstance].pointsFiftyThousandInGame_g ){
            CCLOG(@"50,000 Point Achievement");
            [GameState sharedInstance].pointsFiftyThousandInGame_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kPointsFiftyThousandInGame_g percentComplete:100.0];
        }
    }else if(_totalGameScore >= 100000 && _totalGameScore <= 500000){
        // 100000 Achievement
        if( ![GameState sharedInstance].pointsOneHundredThousandInGame_g ){
            CCLOG(@"100,000 PointAchievement");
            [GameState sharedInstance].pointsOneHundredThousandInGame_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kPointsOneHundredThousandInGame_g percentComplete:100.0];
        }
    }
    
    // Survive 20 Seconds No Damage Achievement
    if(m_bSurvived20SecondsNoDamage && _totalGameTimePlayed >= 20.0f){
        if( ![GameState sharedInstance].survived20SecondsWithNoDamage_g ){
            CCLOG(@"Survived 20 Seconds With No Damage PointAchievement");
            [GameState sharedInstance].survived20SecondsWithNoDamage_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kSurvived20SecondsWithNoDamage_g percentComplete:100.0];
        }
    }
    
    // fire 2000 bullets achievement
    if( _totalShotsFired >= 2000){
        if( ![GameState sharedInstance].fired2000BulletsInOneGame_g ){
            CCLOG(@"Shoot 2000 Times Achievement");
            [GameState sharedInstance].fired2000BulletsInOneGame_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kFired2000BulletsInOneGame_g percentComplete:100.0];
        }
    }
    
    // Use 20 Medkit Achievmenets
    if(m_iMedKitUsageCount >= 20){
        if( ![GameState sharedInstance].used20MedkitsInGame_g ){
            CCLOG(@"used20MedkitsInGame_g PointAchievement");
            [GameState sharedInstance].used20MedkitsInGame_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kUsed20MedkitsInGame_g percentComplete:100.0];
        }
    }
    
    // med kit with full health
    if(m_iMedKitUsageCount == 1 && self.player.health >= 100){
        if( ![GameState sharedInstance].pickupMedkitWithFullHealth_g ){
            CCLOG(@"Med Kit With Full Healkth Achievement");
            [GameState sharedInstance].pickupMedkitWithFullHealth_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kPickupMedkitWithFullHealth_g percentComplete:100.0];
        }

    }
    
    // survive 30 seconds with less than 10 health
    if(m_fTimeSpentWithUnder10Health >= 30.0f){
        if( ![GameState sharedInstance].survivedFor30SecondsWithLessThan10Health_g ){
            CCLOG(@"Med Kit With Full Healkth Achievement");
            [GameState sharedInstance].survivedFor30SecondsWithLessThan10Health_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kSurvivedFor30SecondsWithLessThan10Health_g percentComplete:100.0];
        }

    }
    
    // first point multiplier
    if(m_bFirstMultiplier){
        if( ![GameState sharedInstance].getFirstPointMultiplier_g ){
            CCLOG(@"Med Kit With Full Healkth Achievement");
            [GameState sharedInstance].getFirstPointMultiplier_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kGetFirstPointMultiplier_g percentComplete:100.0];
        }
    }
   
    
    //survivive 15 seconds with no kills
    if(_totalGameTimePlayed >= 15.0 && _totalZombiesKilled == 0){
        if( ![GameState sharedInstance].survive15SecondsWithNoKill_g ){
            CCLOG(@"Med Kit With Full Healkth Achievement");
            [GameState sharedInstance].survive15SecondsWithNoKill_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kSurvive15SecondsWithNoKill_g percentComplete:100.0];
        }
    }
}

-(void)determineOverallAchievementGameStateWithTotalKills:(int)kills timePlayed:(ccTime)timePlayed withPoints:(int)totalPoints{
    
    // compelte first game
    if(m_bFirstGameFinished){
        if( ![GameState sharedInstance].playOneCompleteGame_g ){
            CCLOG(@"Played One Complete Game Achievement");
            [GameState sharedInstance].playOneCompleteGame_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kPlayOneCompleteGame_g percentComplete:100.0];
        }
    }
    //kill 1000
    if(kills >= 1000 && kills < 5000){
        CCLOG(@"kill achiveement if: total life time kills %i", kills);
        if( ![GameState sharedInstance].killed1000_c ){
            CCLOG(@"Played One Complete Game Achievement");
            [GameState sharedInstance].killed1000_c = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kKilled1000_c percentComplete:100.0];
        }
    }
    
    //kill 5000
    if(kills >= 5000 && kills <= 10000){
        if( ![GameState sharedInstance].killed5000_c ){
            CCLOG(@"5000 overall kils Game Achievement");
            [GameState sharedInstance].killed5000_c = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kKilled5000_c percentComplete:100.0];
        }
    }
    
    //24 hrs played  Dunno if this is correct
    CCLOG(@"total time played: %02f", totalTime);

    if(totalTime > (60 * 60 * 24)){
      CCLOG(@"total time played: %02f", totalTime);
        
        if( ![GameState sharedInstance].playedFor24Hours_c ){
            CCLOG(@"Played 24 hours Achievement");
            [GameState sharedInstance].playedFor24Hours_c = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kPlayedFor24Hours_c percentComplete:100.0];
        }
        
    }
    //24 hrs with 75 accuracy
    
    CCLOG(@"TOTAL POINTS: %i", totalPoints);
    // 1,000,000 points
    if(totalPoints >= 1000000){
        if( ![GameState sharedInstance].getOneMillionPoints_c   ){
            CCLOG(@"million point achievement");
            [GameState sharedInstance].getOneMillionPoints_c = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kGetOneMillionPoints_c percentComplete:100.0];
        }
    }
    
    // 500,000 points
    if(totalPoints >= 500000 && totalPoints <= 1000000){
        if( ![GameState sharedInstance].getHalfMillionPoints_c   ){
            CCLOG(@"half million point Achievement");
            [GameState sharedInstance].getHalfMillionPoints_c = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kGetHalfMillionPoints_c percentComplete:100.0];
        }
    }
     //die with no kills
    if(m_bDiedWithNoKils){
        
        if( ![GameState sharedInstance].dieWithNoKills_g ){
            CCLOG(@"played a game with no kills Achievement");
            [GameState sharedInstance].dieWithNoKills_g = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kDieWithNoKills_g percentComplete:100.0];
        }
    }
}

-(void)showGunPickupLabel:(NSString *)name{
    
    _gunPickupNotificationLabel.visible = YES;
    [_gunPickupNotificationLabel setString:name];
    
    CGPoint _point = self.player.position;
    _point.x += 10;
    
    _gunPickupNotificationLabel.position = _point;
    
    [_gunPickupNotificationLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.0],
                                            [CCCallFuncN actionWithTarget:self selector:@selector(removeGunLabel:)], nil]];
}

-(void)showGunUnlockLabel:(NSString *)name{
    
    _gunUnlockNotificationLabel.visible = YES;
    [_gunUnlockNotificationLabel setString:name];
    _gunUnlockNotificationLabel.anchorPoint = CGPointMake(0, 0);
    _gunUnlockNotificationLabel.position = CGPointMake(0, 0);
    //CGPoint _point = self.player.position;
    //_point.x += 10;
    
    //_gunUnlockNotificationLabel.position = _point;
    
    [_gunUnlockNotificationLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:3.0],
                                            [CCCallFuncN actionWithTarget:self selector:@selector(removeGunUnlockLabel:)], nil]];
}

// remove the label from memory
-(void) removeGunLabel: (id) sender
{
    _gunPickupNotificationLabel.visible = NO;
    
}

-(void) removeGunUnlockLabel: (id) sender{
    _gunUnlockNotificationLabel.visible = NO;
}

-(void) activeFlamethrower{
    
    [self.player flamethrowerEnabled];
}


-(void) pauseAllEnemies{
    
    for(int i = 0; i < MAX_BASIC_ENEMY; i++){
        
        EnemyEntity *enemy = [_basicDebugEnemies objectAtIndex:i];
        if(enemy.active){
            
            [[[CCDirector sharedDirector] scheduler] unscheduleUpdateForTarget:enemy];
        }
    }
}

-(void) unPauseAllEnemies{
    
    for(int i = 0; i < MAX_BASIC_ENEMY; i++){
        
        EnemyEntity *enemy = [_basicDebugEnemies objectAtIndex:i];
        if(enemy.active){
            
            [[[CCDirector sharedDirector] scheduler] scheduleUpdateForTarget:enemy priority:-1 paused:NO];
            
        }
    }
}

-(void) tiltWarning{
    [[CCDirector sharedDirector] pause];
    if(!_isPaused){
        
        //get out singleton
        
        _isPaused = YES;
        
        // if( ![[CCDirector sharedDirector] isPaused] ){
        
        
        //  }
        
        //[self pauseAllEnemies];
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        _pauseMenuBackground = [CCLayerColor layerWithColor:ccc4(1,1,1,1) width:s.width height:s.height];
        _pauseMenuBackground.position = CGPointZero;
        CCSprite *m_introSpriteBackground = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        [m_introSpriteBackground setPosition:CGPointMake(winSize.width * 0.5f, winSize.height*0.5)];
        [_pauseMenuBackground addChild:m_introSpriteBackground z:6];
        [self addChild:_pauseMenuBackground z:500]; // increase z index to fix bug
        
        //CCLabelBMFont *_warning = [CCLabelBMFont labelWithString:@"rotate landscape left for performance" fntFile:@"planecrash_18_white.fnt"];
        
    }
}

-(void) store:(id)sender{
    //[[IAdHelper sharedInstance] moveBannerOffScreen];
    CCLOG(@"STORE CLICKED");
    [SceneManager gotoStoreQuick];
}

-(void) spawnBoss{
    /*int randomGrowl = arc4random() % 5;
     NSString *growFileName = [NSString stringWithFormat:@"zombieGrowl%i.mp3", randomGrowl];
     
     //[[SimpleAudioEngine sharedEngine] playEffect:@"zombieGrowl2.mp3"];
     [[SimpleAudioEngine sharedEngine] playEffect:growFileName];
     */
    // XXXXX MAKE THE ENEMY SIZE RAMP UP AND DOWN
    int enemySize = 25;
    
    // Determine where to spawn the target along the Y axis
    //CGSize winSize = [[CCDirector sharedDirector] winSize]; //Get the screensize
    
    int minX = enemySize;
    int maxX = winSize.width - enemySize;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // count freq;
    int _loopCount = 0;
    
    //int _numberOfEnemyToSpawn = [EnemyEntity getEnemySpawnAmountPerType:enemyType];
    
    // XXXXXX Make this variable increase and decrease (think sin curve)
    //int _randomNumberOfEnemyToSpawn = arc4random() % 4;
    
    int _randomNumberOfEnemyToSpawn = 1;
    
    // will need to switch on types
    // bind numerals to boss position in array
    for(int i = MAX_BASIC_ENEMY; i < MAX_BASIC_ENEMY + MAX_BOSS_1_ENEMY; i++){
        
        EnemyTypes _spawnType = BOSS_ZOMBIE_1;
        CGPoint randomSpawn;
        EnemyEntity *enemy = [_basicDebugEnemies objectAtIndex:i];
        
        // RANDOMIZE TYPE HERE
        //  EnemyTypes _spawnType = [self getEnemySpawnType];
        
        if(![enemy active]){
            
            //if(![enemy active] && ([enemy type] == _spawnType) ){
            _randomNumberOfEnemyToSpawn++;
            // Determine where to spawn the target along the Y axis
            int minY = enemySize;
            int maxY = winSize.height - enemySize;
            int rangeY = maxY - minY;
            int actualY = (arc4random() % rangeY) + minY;
            
            int randomDirection = (arc4random() % 4) + 1;
            
            switch(randomDirection){
                case 1:
                    // TOP
                    randomSpawn = ccp(actualX, (winSize.height - enemySize));
                    break;
                    
                case 2:
                    // BOTTOM
                    randomSpawn = ccp(actualX, (0 - enemySize));
                    break;
                    
                case 3:
                    // LEFT
                    randomSpawn = ccp(0 + (enemySize), actualY);
                    break;
                    
                case 4:
                    // RIGHT
                    randomSpawn = ccp( winSize.width + (enemySize) , actualY);
                    break;
                    
                default:
                    break;
            }
            
            //randomSpawn.x = CCRANDOM_0_1() * winSize.width;
            //randomSpawn.y = CCRANDOM_0_1() * winSize.height;
            [enemy setPosition:randomSpawn];
            [enemy setVisibleStatus:YES];
            CCLOG(@"** ENEMY HEALTH WHEN SPAWNED: %i", enemy.health);
            _loopCount++;
            CCLOG(@"_loopCount: %i", _loopCount);
            
            // stop when we reach our desired amount of enemies to spawn
            // if(_loopCount > _randomNumberOfEnemyToSpawn)
            break;
        }
    }
}


@end























