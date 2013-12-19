//
//  SceneManager.m
//  Penguin
//
//  Created by Corey Schaf on 6/13/11.
//  Copyright 2011 EasyXP. All rights reserved.
//

#import "SceneManager.h"
#import "MenuScene.h"
#import "CreditsLayer.h"
#import "StatsLayer.h"
#import "StoreLayer.h"
#import "BannerLayer.h"

@implementation SceneManager



// <summary>
//
// Method: runMenuScene
//
// Purpose: reutrn instance of menu scene, our main menu
//
// </summary>
+(MenuScene*)runMenuScene{
    
    return [MenuScene scene];
}


// <summary>
//
// Method: 
//
// Purpose: 
//
// </summary>

+(GameScene*) runQPGameScene{
    return [GameScene scene];
}

+(CreditsLayer*) runCreditsLayer{
    return [CreditsLayer scene];
}

+(StatsLayer*) runStatsLayer{
    return [StatsLayer scene];
}

+(StoreLayer*) runStoreLayer{
    
    return [StoreLayer scene];
}

+(BannerLayer*) runBannerLayer{
    
    return [BannerLayer scene];
}


// <summary>
//
// Method: 
//
// Purpose: 
//
// </summary>
// This can be optimized if needed
+(CGSize) winSize{
    return [[CCDirector sharedDirector] winSize];
}

// <summary>
//
// Method: 
//
// Purpose: 
//
// </summary>
+(CCScene *) wrap:(CCLayer *)layer{
    
    CCScene *newScene = [CCScene node];
    [newScene addChild: layer];
    
    return newScene;
}

// <summary>
//
// Method: 
//
// Purpose: 
//
// </summary>
+(void) go: (CCLayer *) layer{
    
    CCDirector *_director = [CCDirector sharedDirector];
    
    CCScene *_newScene = [SceneManager wrap:layer];
    
    if ([_director runningScene]) {
        
        [_director replaceScene: _newScene];
        
    }else {
        
        [_director runWithScene:_newScene];
        
    }
    
}

// <summary>
//
// Method: 
//
// Purpose: 
//
// </summary>
+(void) gotoQuickPlay{
    
    //[[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    CCDirector *_director = [CCDirector sharedDirector];
    if( [_director runningScene]){
        
        //[_director replaceScene:[SceneManager runQPGameScene]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runQPGameScene]]];
    }else{
        //[_director runWithScene:[SceneManager runQPGameScene]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runQPGameScene]]];
    }

    
}

// <summary>
//
// Method: 
//
// Purpose: 
//
// </summary>
+(void) gotoMenu{
    
    CCDirector *_director = [CCDirector sharedDirector];

    /////////////////////////////////////
    // fix for ios6 game center portrait
    //[SceneManager runBlankScene];
    /////////////////////////////////////
    
    if( [_director runningScene] ){
        
        
        //[_director replaceScene:[SceneManager runMenuScene]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runMenuScene]]];
    }else{
        //[_director runWithScene:[SceneManager runMenuScene]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runMenuScene]]];
    }

}

// <summary>
//
// Method: 
//
// Purpose: 
//
// </summary>
+(void) gotoCredits{
    CCDirector *_director = [CCDirector sharedDirector];
    if( [_director runningScene]){
        
        //[_director replaceScene:[SceneManager runCreditsLayer]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runCreditsLayer]]];
    }else{
        //[_director runWithScene:[SceneManager runCreditsLayer]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runCreditsLayer]]];
    }

}

// <summary>
//
// Method: 
//
// Purpose: 
//
// </summary>
+(void) gotoStats{
    CCDirector *_director = [CCDirector sharedDirector];
    if( [_director runningScene]){
        
        //[_director replaceScene:[SceneManager runStatsLayer]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runStatsLayer]]];
    }else{
        //[_director runWithScene:[SceneManager runStatsLayer]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runStatsLayer]]];
    }

    
}

+(void) gotoStore{
    CCDirector *_director = [CCDirector sharedDirector];
    if([_director runningScene]){
        //[_director replaceScene:[SceneManager runStoreLayer]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runStoreLayer]]];
    }else{
        //[_director replaceScene:[SceneManager runStoreLayer]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runStoreLayer]]];
    }
}

+(void) gotoStoreQuick{
    CCDirector *_director = [CCDirector sharedDirector];
    if([_director runningScene]){
        [_director replaceScene:[SceneManager runStoreLayer]];
        //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runStoreLayer]]];
    }else{
        [_director replaceScene:[SceneManager runStoreLayer]];
        //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runStoreLayer]]];
    }
}

// ADDED THIS BANNER TO BE RANDOMLY USED TO TRY AND PROMPT IN APP PURCHASES
+(void) gotoBanner{
    CCDirector *_director = [CCDirector sharedDirector];
    if([_director runningScene]){
        //[_director replaceScene:[SceneManager runBannerLayer]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runBannerLayer]]];
    }else{
        //[_director runWithScene:[SceneManager runBannerLayer]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[SceneManager runBannerLayer]]];
    }
}

// <summary>
//
// Method: pushLayer
//
// Purpose: add layer to scene with tag
//
// </summary>
+(void) pushLayer:(CCLayer *)layer onto:(CCScene *)scene withTag:(NodeTags)tag{
    
    [[CCScene node] addChild:layer z:1 tag:tag];
    
}

// <summary>
//
// Method: popLayer
//
// Purpose: remove layer by tag from scene
//
// Notes: no need now, 6/14, possible use with game logic implementation
//
// </summary>
+(void) popLayer:(CCScene *)scene withTag:(NodeTags)tag{

    [scene removeChildByTag:tag cleanup:YES];
}

  

@end






