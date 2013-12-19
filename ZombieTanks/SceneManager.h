//
//  SceneManager.h
//  Penguin
//
//  Created by Corey Schaf on 6/13/11.
//  Copyright 2011 EasyXP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuScene.h"
#import "GameScene.h"

typedef enum{
    
    MenuTag = 1,
    CreditsTag, 
    QuickPlayTag, 
    StatsTag,
    
} NodeTags;

@interface SceneManager : NSObject {
    
}

+(void) gotoMenu;
+(void) gotoCredits;
+(void) gotoStats;
+(void) gotoQuickPlay;
+(void) gotoStore;
+(void) gotoStoreQuick;
+(void) gotoBanner;
+(void) gotoBlank;

+(MenuScene*) getMenuScene;

+(MenuScene*) runMenuScene;

+(GameScene *) getGameScene;
+(GameScene *) runQPGameScene;


+(void) pushLayer:(CCLayer*)layer onto:(CCScene *) scene withTag:(NodeTags )tag;

+(CCScene*) wrap: (CCScene *)scene withLayer:(CCLayer *)layer withTag:(NodeTags )tag;

+(void) popLayer:(CCScene *)scene withTag:(NodeTags)tag;

+(CGSize) winSize;






@end
