//
//  GunEnhancment.h
//  ZombieTanks
//
//  Created by Corey Schaf on 8/8/12.
//
//

#import "IEnhancement.h"
#import "cocos2d.h"
#import "GunModifierComponent.h"


@interface GunEnhancment : IEnhancement{
    
    CCRotateBy *_rotate;
    CCSprite *_sprite;
    //CCSprite *_glow;
    CCBlink *_blinkAction;
    BOOL m_bBlinkControlFlag;
    
    BOOL m_bActive;
    float m_fTimeToLive;
    
    GunModifiers _modifierType;
    GunModifierComponent *_gunModifierComponent;
    
}

@property (assign)BOOL active;
@property (strong) CCSprite* sprite;
@property (strong) CCSprite* glow;
@property (assign) GunModifiers gunModifier;
@property (strong) GunModifierComponent *gunComponent;

+(id) gunEnhancementWithType:(GunModifiers)modifierType withLayer:(CCLayer *)layer;
-(id) initGunEnhancementWithType:(GunModifiers)modifierType withLayer:(CCLayer *)layer;

-(void) makeActiveStatus:(BOOL) activeStatus;
-(void) reset;

@end
