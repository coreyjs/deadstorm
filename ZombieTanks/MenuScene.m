//
//  MenuScene.m
//  Penguin
//
//  Created by Corey Schaf on 6/13/11.
//  Copyright 2011 EasyXP. All rights reserved.
//

#import "MenuScene.h"
#import "SceneManager.h"
#import "SimpleAudioEngine.h"
//#import "IAdHelper.h"
#import "InAppDeadstormHelper.h"
#import "GCHelper.h"

@implementation MenuScene

static MenuScene* instanceOfMenuScene;

// FOR RANDOMIZATION
/*#define INV_MAX_LONGINT                 2.328306e-10f
static unsigned long z = 362436069, w = 521288629;
#define znew()      ((z = 36969 * (z & 65535) + (z >> 16)) << 16)
#define wnew()      ((w = 18000 * (w & 65535) + (w >> 16)) & 65535)
#define IUNI()      (znew() + wnew())
#define UNI()       ((znew() + wnew()) * INV_MAX_LONGINT)
static void setseed(unsigned long i1, unsigned long i2) { z=i1; w=i2; }
*/
// END FOR RANDOMIZATION

+(MenuScene *) sharedMenuScene{
    NSAssert(instanceOfMenuScene != nil, @"MenuScene instance not yet initialized!");
	return instanceOfMenuScene;

}

+(id) scene{
    
	CCScene *scene = [CCScene node];
	
	MenuScene *layer = [MenuScene node];
    
	
	[scene addChild:layer];
	
	return scene;
}



-(id) init{
    
	if( (self = [super init] ) ){        
        // iAds
        // [[IAdHelper sharedInstance] moveBannerOffScreen];
        
		// init everyting here, buttons etc...
        // for the survive button
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"heartbeat1.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"heavyBreathing.wav"];
        // the main song for the game
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"DS_Song.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"gunShot1.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"flameThrowerSound2.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"squish1.mp3"];
        // [[SimpleAudioEngine sharedEngine] preloadEffect:@"squish2.mp3"];
        // [[SimpleAudioEngine sharedEngine] preloadEffect:@"squish3.mp3"];
        // [[SimpleAudioEngine sharedEngine] preloadEffect:@"squish4.mp3"];
        // [[SimpleAudioEngine sharedEngine] preloadEffect:@"squish5.mp3"];
        //[[SimpleAudioEngine sharedEngine] preloadEffect:@"zombieAmbience.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"zombieAttackHitPlayer.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"zombieGrowl1.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"zombieGrowl2.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"zombieGrowl3.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"zombieGrowl4.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"zombieGrowl5.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"grunt.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"reload.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"flameThrowerSound2.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"nukeSound.mp3"]; // NEW NUKE!
		//CGSize winSize = [CCDirector sharedDirector].winSize;

        [self addChild:[MenuLayer node] z:1];
        instanceOfMenuScene = self;
	}
    
    [[CCDirector sharedDirector] resume]; // odd bug, this should fix it MAB
    
	return self;
}




@end


@implementation MenuLayer

// <summary>
// Method: init
// Purpose: init MenuLayer
// </summary>

-(void) onEnter{
    
    [super onEnter];
   // [[GCHelper sharedInstance] authenticateLocalUser];
    
}

-(id) init{
	//self = [super init];
    
	if( self = [super init] ){
        // iAds Added
        // [[IAdHelper sharedInstance] moveBannerOffScreen];
       // [[GCHelper sharedInstance] authenticateLocalUser];
        
		CGSize winSize = [CCDirector sharedDirector].winSize;
        
        
        
        //CCMenuItemImage *m_quickPlay = [CCMenuItemImage itemWithNormalImage:@"QuickPlay_Button.png" selectedImage:@"QuickPlay_Button.png" disabledImage:@"QuickPlay_Button.png" target:self selector:@selector(startGame:)];
        
        CCMenuItemImage *m_quickPlay = [CCMenuItemImage itemWithNormalImage:@"play-button.png" selectedImage:@"play-button-over.png" disabledImage:@"play-button.png" target:self selector:@selector(startGame:)];
    
        //CCMenuItemImage *m_store = [CCMenuItemImage itemWithNormalImage:@"store-button.png" selectedImage:@"store-button-over.png" disabledImage:@"store-button.png" target:self selector:@selector(store:)];
        
        CCMenuItemImage *m_stats = [CCMenuItemImage itemWithNormalImage:@"stats-button.png" selectedImage:@"stats-button-over.png" disabledImage:@"stats-button.png" target:self selector:@selector(stats:)];
        
        CCMenuItemImage *m_credits = [CCMenuItemImage itemWithNormalImage:@"credits-button.png" selectedImage:@"credits-button-over.png" disabledImage:@"credits-button.png" target:self selector:@selector(about:)];
        /*
        CCMenuItemImage *m_quickPlay = [CCMenuItemImage itemWithNormalImage:@"Play_Button.png" selectedImage:@"Play_Button_over.png" disabledImage:@"Play_Button.png" target:self selector:@selector(startGame:)];
        
        CCMenuItemImage *m_store = [CCMenuItemImage itemWithNormalImage:@"store-button.png" selectedImage:@"store-button-over.png" disabledImage:@"store-button.png" target:self selector:@selector(store:)];
        
        CCMenuItemImage *m_stats = [CCMenuItemImage itemWithNormalImage:@"Stats_button.png" selectedImage:@"Stats_button_over.png" disabledImage:@"Stats_button.png" target:self selector:@selector(stats:)];
        
        CCMenuItemImage *m_credits = [CCMenuItemImage itemWithNormalImage:@"Credits_Button.png" selectedImage:@"Credits_Button_over.png" disabledImage:@"Credits_Button.png" target:self selector:@selector(about:)];
         */
        //[m_splashPlayImage setOpacity:1.0];        
		m_menu = [CCMenu menuWithItems:m_quickPlay, m_stats, m_credits, nil];
        
        [m_menu alignItemsVerticallyWithPadding:4];
		[m_menu setPosition:ccp(winSize.width/2, winSize.height/2 - 66)];
        //m_menu.opacity = 0;
        
        // MAB ADDED FADE IN CODE XXXXX
        //CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:1.75 opacity:255];
        //[m_menu runAction:fadeIn];

        
        CCSprite *bg;// = [CCSprite spriteWithFile:@"introscreen.png"];
        
        NSString *model = [[UIDevice currentDevice] model];
        if(winSize.width == 568){
            bg = [CCSprite spriteWithFile:@"Deadstorm-phone5-logo.png"];
        }else{
            bg = [CCSprite spriteWithFile:@"introscreen.png"];
            
        }
        
		//bg.scale = .50;
        //bg.position = ccp(0, 0);
        [bg setPosition:ccp(winSize.width/2, winSize.height/2)];
        //bg.anchorPoint = CGPointMake(0, 1);
        
        [self addChild:bg z:1];
        
		[self addChild:m_menu z:3];
        
        CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"light_smoke_effect.plist"];
        particle.position = CGPointMake(winSize.width * 0.5f, winSize.height * 0.5f);
        //particle.duration = 0.2f;
        //particle.scale = 0.7f;
        
        CCParticleSystemQuad *embers = [CCParticleSystemQuad particleWithFile:@"embers.plist"];
        embers.position = CGPointMake(winSize.width/2, winSize.height);
          
        [self addChild:particle z:2];
        
        [self addChild:embers z:2];
        
        //CCMenuItemFont *_store = [CCMenuItemFont itemWithString:@"STORE" target:self selector:@selector(store:)];
        //CCMenuItemImage *_store = [CCMenuItemImage itemWithNormalImage:@"cash-button.png" selectedImage:@"cash-button-over.png" target:self selector:@selector(store:)];
        //CCMenu *_storeMenu = [CCMenu menuWithItems:_store, nil];
        //[_storeMenu setPosition:ccp(winSize.width-50, 50)];
        
        //[self addChild:_storeMenu z:3];
	}
    
    [[CCDirector sharedDirector] resume]; // odd bug, this should fix it MAB
	return self;
	
}



// <summary>
//
// Method: startGame
//
// Purpose: selector sent to the menu option to start game scene
//          and game logic
//
// </summary>
-(void)startGame:(id) sender
{
    // SHOW ANNOYING AD ONCE IN A WHILE
    /*
     if( ![[InAppDeadstormHelper sharedHelper] productPurchased:kDeadStormRemoveAdsIdentifier] ){   // if they didnt buy yet
        //int random = IUNI() % 4; // 0 - 3
        //CCLOG(@"&&&&&&&&& RANDOM %i", random);
        ////////////////////////////////////////////////
        ////////////////////////////////////////////////
        int bannerCounter = 0;
        // RETREIVE FROM DEVICE
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"ShowBannerCounter"] == nil){
            bannerCounter = 1;
        }
        else{
            bannerCounter = [[NSUserDefaults standardUserDefaults] integerForKey:@"ShowBannerCounter"];
            // HOW ANNOYING DO WE WANT TO BE?
            if(bannerCounter < 5){
                bannerCounter++;
                //CCLOG("BANNER COUNTER: %i", bannerCounter);
            }
            else{
                bannerCounter = 1;
            }
        }
        // SAVE TO DEVICE
        [[NSUserDefaults standardUserDefaults] setInteger:bannerCounter forKey:@"ShowBannerCounter"];
        ////////////////////////////////////////////////
        ////////////////////////////////////////////////
        //int random = (arc4random() % 4);
        // DONT SHOW ALL THE TIME
        //if(random == 2){
        if(bannerCounter == 1){
            [SceneManager gotoBanner];
        }
        else{
            // player lucked out
            [SceneManager gotoQuickPlay];
        }
    }
     */
    //else{
        // PLAYER PAID, STOP SHOWING UP
        [SceneManager gotoQuickPlay];
	//}
}

// <summary>
//
// Method: about
//
// Purpose: selector sent to menu option to replace scene with credits
//
// </summary>
-(void) about:(id)sender{
	
    [SceneManager gotoCredits];
	
}

-(void) store:(id)sender{
    
    [SceneManager gotoStore];
}

-(void) banner:(id)sender{
    // POP UP ANNOYING AD TO BUY
    [SceneManager gotoBanner];
}

// <summary>
//
// Method: stats
//
// Purpose: selector to replace scene with stats layer + scene
//
// </summary>
-(void) stats:(id)sender{
    
    [SceneManager gotoStats];

}


@end














