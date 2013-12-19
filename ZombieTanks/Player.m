//
//  Player.m
//  ZombieTanks
//
//  Created by Corey Schaf on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "Bullet.h"
#import "GameScene.h"
#import "BulletCache.h"
#import "SimpleAudioEngine.h"
#import "GunModifierComponent.h"
#import "SimpleAudioEngine.h"

@implementation Player

@synthesize moving = _moving;
@synthesize health = _health;
@synthesize isShooting = _isShooting;
@synthesize speed = _playerSpeed;
@synthesize absoluteBoundingBox = _absoluteBoundingBox;

//@synthesize lives = _lives;

@synthesize regularProjectiles = _regularBullets;


// THE PLAYER SPEED WHEN HEALTHY VS. INJURED
#define HEALTHY_SPEED 10.0f
#define BADLY_INJURED_SPEED 5.0f

-(id) initWithLayer:(GameScene *)layer type:(int)type hp:(int)hp{
    
    if( self = [super initWithSpriteFrameName:@"player_1_cropped.png"] ){
        
        
        NSMutableArray *animationFrames = [NSMutableArray array];
        int randomSplatter = (arc4random() % 3) + 1;
        NSString *spatFileName = [NSString stringWithFormat:@"bloodSplatter%01d.plist", randomSplatter];
        
        bloodSystem = [CCParticleSystemQuad particleWithFile:spatFileName];
        
        bloodSystem.duration = 0.2f;
        bloodSystem.scale = 0.4f;
        [bloodSystem stopSystem];
        [layer addChild:bloodSystem z:100];

        
       // ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, 
       //     GL_CLAMP_TO_EDGE };
        
       // [self.texture setTexParameters:&texParams];
        _layer = layer;
        
        self.health = hp;
        
        // no longer using lives. Just health in percentage.
        //self.lives = 3;
        [self scheduleUpdateWithPriority:-1];
        
        self.isShooting = NO;
        
       // _nextInactiveRegularBullet = 0;
       // _regularBullets = [[CCArray alloc] initWithCapacity:100];
         
        // init and allocate bullet cache class
       // bulletCache = [[BulletCache alloc] init];
        
        // multiple by .5 instead of divide by 2, faster on CPU computations
        spriteWidth = self.texture.contentSize.width * 0.5f;
        spriteHeight = self.texture.contentSize.height * 0.5f;

        _invincibileTime = 1.5f; // XXXXX v1.1.1. less invincible time. Was 2.0f
        _timeSinceLastTookDamage = 0;
        _canBeDamaged = YES;
        
        // shoot animation
        NSMutableArray *animationFrames2 = [NSMutableArray array];
        [animationFrames2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:@"player_1_cropped.png"]];
        
        for(int i = 1; i < 5; i++){
            
            [animationFrames2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache]
                                        spriteFrameByName:[NSString stringWithFormat:@"player_%d.png", i]]];
        }
        
        [animationFrames2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:@"player_1_cropped.png"]];

        
        _playerAnimation = [CCAnimation animationWithSpriteFrames:animationFrames2 delay:.05f];
        
        //_animation = [CCAnimate actionWithDuration:.1f animation:_playerAnimation restoreOriginalFrame:YES];
        _animation = [CCAnimate actionWithAnimation:_playerAnimation];
        
        // XXXXX USE THIS FOR TESTING DIFFERENT GUN TYPES
        self.gunModifierType = GunModifierBasic;
        //self.gunModifierType = GunModifierNuke;
        
        _blink = [CCBlink actionWithDuration:.5 blinks:2];
        
        m_bBlinkControlFlag = NO;
        
        m_iTotalShotsFired = 0;
        
        _playerSpeed = 10;
        
        // flamethrower
        _flameThrowerGunModifier = [CCParticleSystemQuad particleWithFile:@"flameThrower.plist"];
        [_flameThrowerGunModifier stopSystem];
        _flameThrowerGunModifier.duration = 3.0f;
        _flameThrowerGunModifier.duration = 0.3f;
        [_layer addChild:_flameThrowerGunModifier z:175];
        
    }
    
    return self;
}

-(void) moveToward:(CGPoint)targetPosition{
    _targetPosition = targetPosition;
}

-(void) Blink:(int)howLong{
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.2 opacity:127];
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.2 opacity:255];
    
    CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
    //CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    CCRepeat *repeat = [CCRepeat actionWithAction:pulseSequence times:howLong];  // change this value
    [_playerSprite runAction:repeat];
}

-(void) calcNextMove{
    
}


- (void)updateMove:(ccTime)dt {
    
    // 1
    if (!self.moving) return;
    
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // 2
    //CGPoint oldPosition = self.position;
    CGPoint offset = ccpSub(_targetPosition, self.position);
    // 3
    //float MIN_OFFSET = 10;
   // if (ccpLength(offset) < MIN_OFFSET) return;
    
    // 4
    CGPoint targetVector = ccpNormalize(offset);    
    // 5
    float POINTS_PER_SECOND = 100;
    CGPoint targetPerSecond = ccpMult(targetVector, POINTS_PER_SECOND);
    // 6
    //CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    

    float imageWidthHalved = [self contentSize].width * 0.5f;
    float leftBoarderLimit = imageWidthHalved;
    float bottomBorderLimit = imageWidthHalved;
    float rightBorderLimit = winSize.width - imageWidthHalved;
    float topBoarderLimit = winSize.height - imageWidthHalved;
    
    // changed from actual to target for debvug
    if(_targetPosition.x < leftBoarderLimit){
        _targetPosition.x = leftBoarderLimit;
    }else if(_targetPosition.x >  rightBorderLimit){
        _targetPosition.x = rightBorderLimit;
    }
    // Y
    if(_targetPosition.y > topBoarderLimit){
        _targetPosition.y = topBoarderLimit;
    }else if(_targetPosition.y < bottomBorderLimit){
        _targetPosition.y = bottomBorderLimit;
    }

    self.position = _targetPosition;  
        

}

-(void) update:(ccTime)dt {
    
    [self updateAbsoluteBoundingBox];
    
    [self updateMove:dt];
    
    [self updateShoot:dt];
    
   //[_healthSystem setPosition:self.position];
    
    // we need an incinvicle timer to allow the player
    // at least a chance to survive
    if(!_canBeDamaged){
        _timeSinceLastTookDamage += dt;
        
        // if in this condition, we got hit
        // check for max invincible time
        if(_timeSinceLastTookDamage >= _invincibileTime){
            _canBeDamaged = YES;
            _timeSinceLastTookDamage = 0.0f;
        }
    }
}

-(void) shootToward:(CGPoint)targetPosition{
    
    CGPoint offset = ccpSub(targetPosition, self.position);
   // float MIN_OFFSET = 10;
    
    //if(ccpLength(offset) < MIN_OFFSET) return;

    _shootVector = ccpNormalize(offset);
    
    // We speed up shooting speed by multipling vector by speed of 10, maybe e
    // extract later so we an adjust on the fly
    _shootVector = ccpMult(_shootVector, 20);
   
}


-(void) shootNow{
    m_iTotalShotsFired = m_iTotalShotsFired + 1;
  
    
    // 1
//    CGFloat angle = ccpToAngle(_shootVector);
//    //_turret.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
//    
//    // 2
    float mapMax = MAX([GameScene screenRect].size.width, [GameScene screenRect].size.height);
    CGPoint actualVector = ccpMult(_shootVector, mapMax);  
//    
//    // 3
//    float POINTS_PER_SECOND = 300;
//    float duration = mapMax / POINTS_PER_SECOND;
//    
//    // 4
//    // NSString * shootSound = [NSString stringWithFormat:@"tank%dShoot.wav", _type];
//    //[[SimpleAudioEngine sharedEngine] playEffect:shootSound];
//
//    // get bullet from cache here
    [self shootToward:actualVector];
    
    //[_layer.bulletCache shootBulletFrom:ccpAdd(self.position, ccpMult(_shootVector, 1)) velocity:_shootVector frameName:@"yellow_bullet.png" isPlayerBullet:YES currentGunModifier:self.gunModifierType];
    [_layer.bulletCache shootBulletFrom:ccpAdd(self.position, ccpMult(_shootVector, 1)) velocity:_shootVector frameName:@"bullet_3.png" isPlayerBullet:YES currentGunModifier:self.gunModifierType rotation:self.rotation];
    
    CCLOG(@"TotalShotsFired: %i GetShotLimitPerPickup: %i", m_iTotalShotsFired, ([GunModifierComponent getShotLimitPerPickup:self.gunModifierType]));
    
    if(m_iTotalShotsFired >= [GunModifierComponent getShotLimitPerPickup:self.gunModifierType]){
        
        CCLOG(@"******************** HERE **************************");
        // reverted
        CCLOG(@"Reverted gun type back to GunModifierBasic: ShotsFired: %i", m_iTotalShotsFired);
        // MAB BUG - GUN NOT REVERTING!
        
        self.gunModifierType = GunModifierBasic;
        m_iTotalShotsFired = 0;
        
        // CLIP SOUND RESETTING GUN
    }
    
    // ONLY ONE SHOT
    /*if(self.gunModifierType == GunModifierNuke){
        self.gunModifierType = GunModifierBasic;
        m_iTotalShotsFired = 0;
    }*/
    
    // how can we get this effect to be quieter
    if(_gunModifierType != GunModifierFlamethrower && _gunModifierType != GunModifierNuke){
        [[SimpleAudioEngine sharedEngine] playEffect:@"gunShot1.wav"]; // wav file is quieter gunshot sound
    }
    // NUKE SOUND
    else if(_gunModifierType == GunModifierNuke){
        // XXXXX flame thrower sound should be played here
        [[SimpleAudioEngine sharedEngine] playEffect:@"nukeSound.mp3"];
    }
    // FLAME THROWER
    else{
        // XXXXX flame thrower sound should be played here
        [[SimpleAudioEngine sharedEngine] playEffect:@"flameThrowerSound2.mp3"];
    }

    _isShooting = NO;
    
    
    if(self.gunModifierType != GunModifierFlamethrower){
        [self runAction:_animation];
    }
}


-(BOOL) shouldShoot{
    
    //CCLOG(@"Shooting: %@", _isShooting);
    
    if( !self.isShooting) return NO;
    
    // TODO: Do we limit time between shots??
    double SECS_BETWEEN_SHOTS = 0;
    if( _timeSinceLastShot > SECS_BETWEEN_SHOTS ){
        _timeSinceLastShot = 0;
        return YES;
    }else {
        return NO;
    }
}

-(void) updateShoot:(ccTime)dt{

    _timeSinceLastShot += dt;
    //self.visible = YES;
    if( [self shouldShoot] ){
        
        [self shootNow];
    }
}

-(BOOL) gotHit:(int)dmg{
    
    if(_canBeDamaged){
        
        _canBeDamaged = NO;
        _health -= dmg;
        
        // GAME OVER!
        if(_health <= 0){
            // negative hp bug fix.
            _health = 0;
            return NO;
            
        }
        else{
            // still alive
            // play zombie groan sound
            [[SimpleAudioEngine sharedEngine] playEffect:@"zombieAttackHitPlayer.wav"];
            
            [self gotHitAnimations];
            
            // badly hurt, less speed (act like limping)
            if(self.health <= 25){
                _playerSpeed = BADLY_INJURED_SPEED;
            }
            else{
                _playerSpeed = HEALTHY_SPEED;
            }
            
            return YES;
        }
        
    }
    
    return YES;
}

-(void) playHealthSystem{
    
    _healthSystem.position = self.position;
    [_healthSystem resetSystem];
}

-(void) addHealth:(int)hp{
    
    if(self.health > 0){
        self.health += hp;
    }
    else{
        // maybe prevent any negative values in the HUD
        self.health = 0;
    }
    
    if(self.health > 100){
        self.health = 100;
    }
    
    // badly hurt, less speed (act like limping)
    if(self.health <= 25){
        _playerSpeed = BADLY_INJURED_SPEED;
    }
    else{
        _playerSpeed = HEALTHY_SPEED;
    }
}

-(void) gotHitAnimations{
    
    // VIBRATE THE DEVICE
    CCLOG(@"PlayerGotHit function called!");
    
    // [_hudLayer setHp:_player.health];
    
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    
    // PLAYER GRUNT SOUND FROM GETTING HIT.
    [[SimpleAudioEngine sharedEngine] playEffect:@"grunt.wav"];
    
    // XXXXX PLAY SQUISH AUDIO EFFECT 1 TIME
    
    // XXXXX PLAY "GRUNT AUDIO EFFECT 1 TIME
    
    // USE A RANDOM BLOOD SPLATTER TO SPRAY ACROSS THE SCREEN
    int randomNum = (arc4random() % 1) + 1;
    
    NSString *bloodFilename = [NSString stringWithFormat:@"gotHit%1dfade.png", randomNum];
    // RANDOMIZE BLOOD SPLATTER
    CCSprite* playerHitBlood = [CCSprite spriteWithSpriteFrameName:bloodFilename];
    //playerHitBlood.anchorPoint = CGPointMake(0, 0);
    [self addChild: playerHitBlood z:180];
    [playerHitBlood runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.3], [CCCallFuncN actionWithTarget:self selector:@selector(removeLabel:)], nil]];
    
    // PLAYER HIT SO CAUSE THE SCREEN TO SHAKE
    //                    id shakeAction = [CCShaky3D actionWithRange:10 shakeZ:YES grid:ccg(2,2) duration:0.6];
    //                    id shakeStop = [CCStopGrid action];
    //                    id sequence = [CCSequence actions:shakeAction, shakeStop, nil];
    //                    [self runAction:sequence];
    
    //[self unschedule:@selector(PlayerGotHit)];
    
    
    
    // BUG IN HERE
    // [self stopAction:_blink];
    // self.visible = YES;
    // [self runAction:_blink];
    self.visible = YES;
    
    
}

-(void) playBloodSystem{
    
    //bloodSystem.position = _sprite.position;
    bloodSystem.position = self.position;
    [bloodSystem resetSystem];
}

-(void) setVisibleStatus:(BOOL) visibility{
    
    self.visible = visibility;
}


-(void) removeLabel: (id) sender
{
    [self removeChild:sender cleanup:YES];
    
}

// resets the bullet count of the current gun modifier type
-(void) resetBulletTracker{
    
    m_iTotalShotsFired = 0;
}

-(void) updateAbsoluteBoundingBox{
    
    //_absoluteBoundingBox = self.boundingBox;
    
    _absoluteBoundingBox = CGRectMake(self.boundingBox.origin.x,
                                      self.boundingBox.origin.y,
                                      self.boundingBox.size.width * 0.5,
                                      self.boundingBox.size.height * 0.5);
}

-(CGRect *) flamethrowerEnabled{
    
    //CGRect *flameBB = _flameThrowerGunModifier.boundingBox;
    float internalRotation = self.rotation;
    
    _flameThrowerGunModifier.position = self.position;
    
    
    if(self.rotation < 0){
        internalRotation = 360 - (self.rotation * -1);
    }
    
    _flameThrowerGunModifier.rotation = internalRotation;
    
    
    [_flameThrowerGunModifier resetSystem];
    
    return nil;
}

@end



































