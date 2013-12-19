//
//  GunModifierComponent.m
//  ZombieTanks
//
//  Created by Corey Schaf on 8/7/12.
//
//

#import "GunModifierComponent.h"

@implementation GunModifierComponent

@synthesize count = m_iCurrentGunModificationBulletCount;

+(int) getShotLimitPerPickup:(GunModifiers)gunModifierType{
    
    int _count;
    
    switch (gunModifierType) {
        case GunModifierBasic:
            _count = 1000000;
            break;
        case GunModifierDouble:
            _count = 40;
            break;
        case GunModifierHollowPoint:
            _count = 50;
            break;
        case GunModifierTriple:
            _count = 35;
            break;
        case GunModifierFullAuto:
            _count = 100;
            break;
        case GunModifierFlamethrower:
            _count = 20;
            break;
        case GunModifierNuke:
            _count = 2;  // player gets only one nuke
            break;
        default:
            _count = 1000000;
            break;
    }
    
    return _count;
}
    

+(NSString *) getGunModifierComponentName:(GunModifiers)gunModifierType{
    
    NSString *_name;
    // these need to be lower case so the font atlas works.
    switch (gunModifierType) {
        case GunModifierBasic:
            _name = @"handgun";
            break;
        case GunModifierDouble:
            _name = @"double shot";
            break;
        case GunModifierTriple:
            _name = @"scatter shot";
            break;
        case GunModifierHollowPoint:
            _name = @"hollow point";
            break;
        case GunModifierFlamethrower:
            _name = @"flamethrower";
            break;
        case GunModifierFullAuto:
            _name = @"full auto";
            break;
        case GunModifierNuke:
            _name = @"nuke";
            break;
        default:
            break;
    }
    
    return _name;
}

+(id) GunModiferComponent{
    return [[self alloc] initGunModiferComponent];
}

-(id) initGunModiferComponent{
    
    if((self = [super init])){
        
        m_iCurrentGunModificationBulletCount = 0;
    }
    
    return self;
}

-(void) incrementCount{
    
    m_iCurrentGunModificationBulletCount++;
}

-(void) resetVariables{
    m_iCurrentGunModificationBulletCount = 0;
}


@end
