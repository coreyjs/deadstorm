//
//  GunEnhancment.m
//  ZombieTanks
//
//  Created by Corey Schaf on 8/8/12.
//
//

#import "GunEnhancment.h"

@implementation GunEnhancment

#define kTotalTimeToLive 10
#define kInitialBLinkTime 8

@synthesize active = m_bActive;
@synthesize sprite = _sprite;
@synthesize glow = _glow;
@synthesize gunModifier = _modifierType;
@synthesize gunComponent = _gunModifierComponent;

+(id) gunEnhancementWithType:(GunModifiers)modifierType withLayer:(CCLayer *)layer{
    
    return [[self alloc] initGunEnhancementWithType:modifierType withLayer:layer];
}

-(id) initGunEnhancementWithType:(GunModifiers)modifierType withLayer:(CCLayer *)layer{
    
    if((self = [super init])){
        
        m_bActive = NO;
        _modifierType = modifierType;
        
        
        if(_modifierType == GunModifierNuke){
            _sprite = [CCSprite spriteWithSpriteFrameName:@"ammoBox.png"]; // NUKE IMAGE
            //_sprite = [CCSprite spriteWithFile:@"nukeAmmoBox.png"];
        }
        else{
            // use the enum value of type (0, 1, 2, etc) to append to texture name
            _sprite = [CCSprite spriteWithSpriteFrameName:@"ammoBox3.png"];
        }
        // XXXXX Add to texture sheet
       
        _sprite.visible = NO;
        
        _blinkAction = [CCBlink actionWithDuration:2 blinks:5];
        m_bBlinkControlFlag = NO;
        
        //[self makeStatus:NO];
        _rotate = [CCRotateBy actionWithDuration:3.0 angle:360];
        m_fTimeToLive = 0;

    }
    
    return self;
}


-(void) makeActiveStatus:(BOOL)active{
    
    m_bActive = active;
    _sprite.visible = active;
    
    if(m_bActive){
        
        [[[CCDirector sharedDirector] scheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
        [_sprite runAction:[CCRepeatForever actionWithAction:_rotate]];
        
    }else{
        [[[CCDirector sharedDirector] scheduler] unscheduleUpdateForTarget:self];
        [_sprite stopAllActions];
    }
}

#define kTotalTimeToLive 10

-(void) update:(ccTime)dt{
    
    m_fTimeToLive += dt;
    
    if(m_fTimeToLive >= 8 && m_fTimeToLive <= 10 && !m_bBlinkControlFlag){
        [_sprite runAction:_blinkAction];
        m_bBlinkControlFlag = YES;
    }
    else if(m_fTimeToLive >= kTotalTimeToLive){
        m_bBlinkControlFlag = NO;
        [_sprite stopAllActions];
        [self makeActiveStatus:NO];
    }
    //else{
    //    m_bBlinkControlFlag = NO;
    //    [_sprite stopAllActions];
    //    [self makeActiveStatus:NO];
    //}
}

-(void) reset{
    m_bActive = NO;
    [self makeActiveStatus:NO];
    m_fTimeToLive = 0;
}

@end










