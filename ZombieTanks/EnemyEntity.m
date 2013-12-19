//
//  EnemyEntity.m
//  ZombieTanks
//
//  Created by Corey Schaf on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnemyEntity.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"

@implementation EnemyEntity

@synthesize speed = _speed;
@synthesize sprite = _sprite;
@synthesize moving = _moving;
@synthesize walkAction = _walkAction;
@synthesize active = _active;
@synthesize absoluteBoundingBox = _absoluteBoundingBox;
@synthesize type = _type;
@synthesize emitter;
@synthesize health = _health;

+(int) getEnemySpawnAmountPerType:(EnemyTypes)type{
    
    int count;
    
    switch (type) {
        case 0:
            count = arc4random() % 8;
            //count = 80;
            break;
            
        case 1:
            count = arc4random() % 6;
            //count = 100;
            break;
            
        case 2:
            count = arc4random() % 4;
            //count = 150;
            break;
            
        case 3:
            count = 4;
            break;
            
        default:
            count = 4;
            break;
    }
    
    return count;
}

+(int) getEnemyAttackDamage:(EnemyTypes)type{
    
    int dmg;
    
    switch(type){
        case 0: dmg = 15;
            break;
        case 1: dmg = 25;
            break;
        case 2: dmg = 25;
            break;
        case 3: dmg = 35;
            break;
        case 4: dmg = 45;
            break;
        default:
            dmg = 10;
            break;
            
    }
    
    return dmg;
}

+(int) getEnemyKillPoints:(EnemyTypes)type{
    
    int _killPoints;
    switch (type) {
        case 0:
            _killPoints = 25;
            break;
        case 1:
            _killPoints = 35;
            break;
        case 2:
            _killPoints = 40;
            break;
        case 3:
            _killPoints = 55;
            break;
        case 4:
            _killPoints = 4000;
            break;
        default:
            _killPoints = 20;
            break;
    }
    
    return _killPoints;
    
}

+(id) enemyWithType:(EnemyTypes)type withLayer:(GameScene *)layer{
    
    return [[self alloc] initWithType:type withLayer:layer];
}

+(id) enemyWithType:(EnemyTypes)type{
    
    return [[self alloc] initWithType:type];
}

-(id) initWithType:(EnemyTypes)type withLayer:(GameScene *) layer{
    
    if(( self = [super init] )){
        
        NSMutableArray *animationFrames = [NSMutableArray array];
        int randomSplatter = (arc4random() % 3) + 1;
        NSString *spatFileName = [NSString stringWithFormat:@"bloodSplatter%01d.plist", randomSplatter];
        
        bloodSystem = [CCParticleSystemQuad particleWithFile:spatFileName];
        
        bloodSystem.duration = 0.2f;
        bloodSystem.scale = 0.4f;
        [bloodSystem stopSystem];
        [layer addChild:bloodSystem z:100];
        // _active = NO;
        
        _score = [CCLabelTTF labelWithString:@"" fontName:@"Times New Roman" fontSize:11];
        _score.visible = NO;
        [layer addChild:_score z:100];
        
        
        // due to shit programming, we must check and override the randomization of
        // setting the zombie type, if we declare boss, make a boss
        if(type != BOSS_ZOMBIE_1)
            type = arc4random() % 4;
        _damage = [EnemyEntity getEnemyAttackDamage:type];
        
        
        //type = BOSS_ZOMBIE_1;
        switch (type) {
            case 0:
                _sprite = [CCSprite spriteWithSpriteFrameName:@"basic_zombie_1.png"];
                
                // ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE,
                ///     GL_CLAMP_TO_EDGE };
                // [_sprite.texture setTexParameters:&texParams];
                
                _sprite.visible = NO;
                
                _speed = 100;
                _health = 1;
                _staticHealth = 1;
                //_damage = 5;
                
                for(int i = 1; i < 7; i++){
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache]
                                                spriteFrameByName:[NSString stringWithFormat:@"basic_zombie_%d.png", i]]];
                }
                
                //  _walkAnimation = [CCAnimation animationWithAnimationFrames:animationFrames delayPerUnit:0.175f loops:4];
                _walkAnimation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.175f];
                
                _absoluteBoundingBox = [_sprite boundingBox];
                _type = BASIC_ZOMBIE;
                break;
                
            case 1:
                _sprite = [CCSprite spriteWithSpriteFrameName:@"basic_zombie_2.png"];
                _sprite.visible = NO;
                _speed = 70;
                _staticHealth = 1;
                _health = 1;
                //_damage = 10;
                
                for(int i = 1; i < 7; i++){
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"basic_zombie_2_%d.png", i]]];
                }
                
                _walkAnimation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.175f];
                _absoluteBoundingBox = [_sprite boundingBox];
                _type = BASIC_ZOMBIE_2;
                break;
                
            case 2:
                _sprite = [CCSprite spriteWithSpriteFrameName:@"basic_zombie_3.png"];
                _sprite.visible = NO;
                _speed = 60;
                _staticHealth = 2;
                _health = 2;
                //_damage = 10;
                
                for(int i = 1; i < 7; i++){
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"basic_zombie_3_%d.png", i]]];
                }
                
                _walkAnimation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.175f];
                _absoluteBoundingBox = [_sprite boundingBox];
                _type = BASIC_ZOMBIE_3;
                break;
                
            case 3:
                _sprite = [CCSprite spriteWithSpriteFrameName:@"crawlingZombie_1.png"];
                _sprite.visible = NO;
                _speed = 15;
                _staticHealth = 3;
                _health = 3;
                //_damage = 10;
                
                for(int i = 1; i < 9; i++){
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"crawlingZombie_%d.png", i]]];
                }
                
                _walkAnimation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.175f];
                _absoluteBoundingBox = [_sprite boundingBox];
                _type = SLOW_ZOMBIE;
                break;
                
            // ZOMBIE BOSS 
            case 4:
                
                _sprite = [CCSprite spriteWithSpriteFrameName:@"BossZombie-1.png"];
                _sprite.visible = NO;
                _speed = 32;
                _staticHealth = 75;
                _health = 32;   // SCALED DOWN GAME BALANCING
                
                for(int i = 1; i < 7; i++){
                    
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"BossZombie-%d.png", i]]];
                    
                    _walkAnimation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.175f];
                    _absoluteBoundingBox = [_sprite boundingBox];
                    _type = BOSS_ZOMBIE_1;
                }
                
                break;
                
            default:
                break;
        }
        
        _active = false;
        _layer = layer;
        
        // [_sprite schedule:@selector(move:) interval:0.5];
        
        //[[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
        
        //        [[[CCDirector sharedDirector] scheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
    }
    
    return self;
}


-(void) gotShot:(int)damage{
    
    _health -= damage;
    
}

-(void) setVisibleStatus:(BOOL) visibility{
    
    _sprite.visible = visibility;
    // set enemy to active or inactive
    _active = visibility;
    self.health = _staticHealth;
    
    // if the enemy is active
    if(_active){
       
        [[[CCDirector sharedDirector] scheduler] scheduleUpdateForTarget:self priority:-1 paused:NO];
        self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_walkAnimation]];
        [_sprite runAction:_walkAction];
        
    }else{
        [_sprite stopAllActions];
        [[[CCDirector sharedDirector] scheduler] unscheduleUpdateForTarget:self];
        // are they fully deleted?
    }
}

-(void) setPosition:(CGPoint)position{
    
    _sprite.position = position;
    _position = position;
}

// From http://playtechs.blogspot.com/2007/03/raytracing-on-grid.html
- (BOOL)clearPathFromTileCoord:(CGPoint)start toTileCoord:(CGPoint)end
{
    int dx = abs(end.x - start.x);
    int dy = abs(end.y - start.y);
    int x = start.x;
    int y = start.y;
    int n = 1 + dx + dy;
    int x_inc = (end.x > start.x) ? 1 : -1;
    int y_inc = (end.y > start.y) ? 1 : -1;
    int error = dx - dy;
    dx *= 2;
    dy *= 2;
    
    for (; n > 0; --n)
    {
        if ([_layer isWallAtTileCoord:ccp(x, y)]) return FALSE;
        
        if (error > 0)
        {
            x += x_inc;
            error -= dy;
        }
        else
        {
            y += y_inc;
            error += dx;
        }
    }
    
    return TRUE;
}

-(void) moveToward:(CGPoint)targetPosition{
    // TODO: FIX THIS CODE
    //_targetPosition = targetPosition;
    
    //[self setPosition:_targetPosition];
    
    // targetPosition = playerPosition
    
    // create vector in direction you want to move
    CGPoint moveVector;
    
    moveVector.x = targetPosition.x - _position.x;
    moveVector.y = targetPosition.y - _position.y;
    
    // normalize the vector.  divide the terms by the magnitude (hypotenuse) of vector
    double hyp = sqrt( (moveVector.x * moveVector.x) + (moveVector.y * moveVector.y) );
    
    moveVector.x /= hyp;
    moveVector.y /= hyp;
    
    // now just need to add that vector to the enemys position, multiplied by the speed you want
    
    _position.x += moveVector.x * (_speed * _frameInterval);
    _position.y += moveVector.y * ( _speed * _frameInterval);
    
    //_position = ccpMult(ccpNormalize(_position), _speed);
    [self setPosition:_position];
}

- (void)calcNextMove {
    
//    BOOL moveOK = YES;
//    CGPoint start = _position;
//    CGPoint end;
//    
    self.moving = YES;
    CGPoint playerLocation = [_layer getPlayerLocation];
    
    float angle = CC_RADIANS_TO_DEGREES(atan2(_position.y - playerLocation.y, 
                                              _position.x - playerLocation.x));
    
    angle += 90;
    angle *= -1;
    //float angleRadians = CC_DEGREES_TO_RADIANS(angle);
    
    //float roateSpeed = 0.2 / M_PI;
    //float roatationDuration = fabsf(angleRadians * roateSpeed);

    _sprite.rotation = angle;
    
    [self moveToward:playerLocation];

}

-(void) move:(ccTime)dt{
   // 
   // CCLOG(@"In Enemy 1 Move");
    //if(self.moving && arc4random() % 3 != 0) return;
    [self calcNextMove];
}

-(void) update:(ccTime)dt{
    
    //if(!_active) return;
    
   // CCLOG(@"In update for enemy sprite");
    _frameInterval = dt;
    
    // check for dead enemies
    if(_health <= 0){
        
        //set up death animation
        [self setVisibleStatus:NO];
        //_active = false;
    }
    
    [self move:dt];
    [self updateAbsoluteBoundingBoxRect];
}

-(void) updateAbsoluteBoundingBoxRect{

    // Update bounding box with respect to current position of sprite
//    _absoluteBoundingBox = CGRectMake([_sprite boundingBox].origin.x + 10, [_sprite boundingBox].origin.y + 10, [_sprite boundingBox].size.width - 10, [_sprite boundingBox].size.height - 10);
//    
    //_absoluteBoundingBox = CGRectMake(CGFloat x, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    
    _absoluteBoundingBox = CGRectMake([_sprite boundingBox].origin.x , [_sprite boundingBox].origin.y, [_sprite boundingBox].size.width , [_sprite boundingBox].size.height );
    
}

-(void) playBloodSystem{
    
    //bloodSystem.position = _sprite.position;
    bloodSystem.position = _position;
    [bloodSystem resetSystem];
}

-(void) spawnSelf{
    
    
    CGPoint randomSpawn;
    
 
    
    randomSpawn = CGPointMake(10, 10);

    [self setPosition:randomSpawn];
    [self setVisibleStatus:YES];
   // [self setActive:YES];
    
}

-(void) showScore:(NSString*)points{
    
    _score.visible = YES;
    [_score setString:points];
    _score.position = _sprite.position;
    
    [_score runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.4], [CCCallFuncN actionWithTarget:self selector:@selector(removeLabel:)], nil]];
}

// remove the label from memory
-(void) removeLabel: (id) sender
{
    _score.visible = NO;
    
}


@end































