//
//  HealthEnhancement.m
//  ZombieTanks
//
//  Created by Corey Schaf on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HealthEnhancement.h"

@implementation HealthEnhancement

@synthesize active = m_bActive;
@synthesize sprite = _sprite;

+(id) healthEnhancementWithHealth:(int) health withLayer:(CCLayer *)layer{
    
    return [[self alloc] initHealthEnhancementWithHealth:health withLayer:layer];
}

-(id) initHealthEnhancementWithHealth:(int) health withLayer:(CCLayer *)layer{

    if( (self = [super init]) ){
        
        m_iHealthAmount = health;
        
        // this holds our originial health amount, so we can reset
        m_iHealthAmountStatic = health;
        m_bActive = NO;
        
        _sprite = [CCSprite spriteWithSpriteFrameName:@"medkit.png"];
        _sprite.visible = NO;
        
        _blinkAction = [CCBlink actionWithDuration:2 blinks:5];
        m_bBlinkControlFlag = NO;
        _rotate = [CCRotateBy actionWithDuration:3.0 angle:-360];
        m_fTimeToLive = 0;
    }
    
    return self;
}

-(void) reset{
    
    m_iHealthAmount = m_iHealthAmountStatic;
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

-(int) getHealthAmount{
    
    return m_iHealthAmount;
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
