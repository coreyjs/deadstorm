//
//  CreditsLayer.h
//  ZombieTanks
//
//  Created by Corey Schaf on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface StatsLayer : CCLayer {
    
    CCSprite *_backgroundImage;
    CCSprite *_creditsImage;
    CGSize   winSize;
    CCMenu   *m_menu;
    
    CCMenu *_creditsMenu;
    CCMenuItemImage *_back;
    CCMenuItemImage *_websiteImage;
    
    NSString *_tweetMessage;
    
}
-(void) ViewGameStats;
+(id) scene;

@end
