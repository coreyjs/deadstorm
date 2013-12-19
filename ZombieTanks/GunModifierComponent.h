//
//  GunModifierComponent.h
//  ZombieTanks
//
//  Created by Corey Schaf on 8/7/12.
//
//

#import <Foundation/Foundation.h>

typedef enum{
    GunModifierBasic = 0,
    GunModifierDouble = 1,
    GunModifierHollowPoint = 2,
    GunModifierTriple = 3,
    GunModifierFlamethrower = 4,
    GunModifierNuke = 5,       // ADDED MAB XXXXX
    GunModifierFullAuto = 6
    
} GunModifiers;

@interface GunModifierComponent : NSObject{
    
    // these track the current amount for each
    int m_iCurrentBasicBullets;
    int m_iCurrentDoubleBullets;
    int m_iCurrentTripleBullets;
    int m_iCurrentFullAutoBullets;
    int m_iCurrentFlamethrowerBullets;
    
    int m_iCurrentGunModificationBulletCount;
    
}

@property (assign) int count;

+(int) getShotLimitPerPickup:(GunModifiers)gunModifierType;
+(id) GunModiferComponent;
+(NSString*) getGunModifierComponentName:(GunModifiers)gunModifierType;

-(id) initGunModifierComponent;
-(void) resetVariables;
-(void) incrementCount;
@end
