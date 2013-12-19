//
//  GunPickup.h
//  ZombieTanks
//
//  Created by Corey Schaf on 8/12/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IEnhancement.h"


typedef enum{
    GunModifierBasic = 0,
    GunModifierDouble = 1,
    GunModifierTriple = 2,
    GunModifierFullAuto = 3,
    GunModifierFlamethrower = 4
} GunModifier;


@interface GunPickup : IEnhancement{
    
    BOOL m_bActive;
    float m_fTimeToLive;
    
    CCRotateBy *_rotate;
    CCSprite *_sprite;
    CCBlink *_blinkAction;
    
    BOOL m_bBlinkControlFlag;

}


@property (assign) BOOL active;
@property (strong) CCSprite* sprite;

+(id) gunEnhancementWithType:(GunModifier)modifierType;
-(id) initGunEnhancementWithType:(GunModifier)modifierType; 

-(void) makeActiveStatus:(BOOL)active;
-(int) getHealthAmount;

-(void) reset;

@end
