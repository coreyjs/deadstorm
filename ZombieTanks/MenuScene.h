//
//  MenuScene.h
//  Penguin
//
//  Created by Corey Schaf on 6/13/11.
//  Copyright 2011 EasyXP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MenuScene : CCScene {
    
}

+(id) scene;
@end

@interface MenuLayer : CCLayer{
    
    // Will Replace these with images when the time sees fit
    CCMenuItemFont *m_fontCredits;
    CCMenuItemFont *m_fontQuickplay;
    CCMenuItemFont *m_fontStats;
    
    CCMenuItemImage *m_imageCredits;
    CCMenuItemImage *m_imageQuickplay;
    CCMenuItemImage *m_imageStats;
    
    CCMenu         *m_menu;
    
    CCSpriteBatchNode *_menuBatchNode;
}

+(MenuScene *) sharedMenuScene;

@end