//
//  CreditsLayer.h
//  ZombieTanks
//
//  Created by Corey Schaf on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CreditsLayer : CCLayer {
    
    CCSprite *_backgroundImage;
    CCSprite *_creditsImage;
    
    CCMenu         *m_menu;
    
    CCMenu *_creditsMenu;
    CCMenuItemImage *_back;
    CCMenuItemImage *_websiteImage;
    CGSize   winSize;
}

+(id) scene;

@end
