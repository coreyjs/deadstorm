//
//  GunPickup.m
//  ZombieTanks
//
//  Created by Corey Schaf on 8/12/12.
//
//

#import "GunPickup.h"

@implementation GunPickup

+(id) gunEnhancementWithType:(GunModifier)modifierType{
    
    return [[self alloc] initGunEnhancementWithType:modifierType];
}

-(id) initGunEnhancementWithType:(GunModifier)modifierType{
    
    if( (self = [super init]) ){
     
        m_bActive = NO;
        
        _sprite = [CCSprite spriteWithSpriteFrameName:@"ammoBox.png"];
        _sprite.visible = NO;
        
        _blinkAction = [CCBlink actionWithDuration:2 blinks:5];
        m_bBlinkControlFlag = NO;
        _rotate = [CCRotateBy actionWithDuration:3.0 angle:-360];
        m_fTimeToLive = 0;

        
    }
    
    return self;
}

-(void) reset{
    
    m_bActive = NO;
    [self makeActiveStatus:NO];
    m_fTimeToLive = 0;
    
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
}

@end
