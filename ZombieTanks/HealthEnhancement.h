//
//  HealthEnhancement.h
//  ZombieTanks
//
//  Created by Corey Schaf on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IEnhancement.h"


@interface HealthEnhancement : IEnhancement{ 
    
    int m_iHealthAmount;
    int m_iHealthAmountStatic;
    BOOL m_bActive;
    float m_fTimeToLive;
    
    CCRotateBy *_rotate;
    CCSprite *_sprite;
    CCBlink *_blinkAction;
    
    BOOL m_bBlinkControlFlag;
}

@property (assign) BOOL active;
@property (strong) CCSprite* sprite;

+(id) healthEnhancementWithHealth:(int) health withLayer:(CCLayer *)layer;
-(id) initHealthEnhancementWithHealth:(int) health withLayer:(CCLayer *)layer;
-(void) makeActiveStatus:(BOOL)active;
-(int) getHealthAmount;

-(void) reset;

@end
