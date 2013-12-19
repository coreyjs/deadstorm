//
//  CreditsLayer.m
//  ZombieTanks
//
//  Created by Corey Schaf on 6/28/12.
//  Updated by Mike Bielat on 7/13/2012. Added ability to go back to main menu from the credits screen.

//  TODO: Make the www.BlaqkSheep.com take you to our website?

//  Copyright (c) 2012 blaQk Sheep. All rights reserved.
//

#import "CreditsLayer.h"
#import "SceneManager.h"
//#import "IAdHelper.h"
#import "InAppDeadstormHelper.h"

@implementation CreditsLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    	// 'layer' is an autorelease object.
	CreditsLayer *layer = [[CreditsLayer alloc] init];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
   	
	// return the scene
	return scene;
}

-(id) init{

    /*if( (self = [super init]) ){
        
        self.isTouchEnabled=YES;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        _creditsImage = [CCSprite spriteWithFile:@"CreditsScreen.png"];
        [_creditsImage setPosition:CGPointMake(winSize.width*0.5f, winSize.height*0.5f)];
        [self addChild:_creditsImage z:1];

    }*/
    winSize = [[CCDirector sharedDirector] winSize];
    
    //self = [super init];
	if( self = [super init] ){
        
        /*
         if( ![[InAppDeadstormHelper sharedHelper] productPurchased:kDeadStormRemoveAdsIdentifier] ){
            [[IAdHelper sharedInstance] moveBannerOnScreen];
        }
         */
        
        // this is the ground.
        CCSprite* background;//
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        if(winSize.width == 568){
            background = [CCSprite spriteWithFile:@"grating-bkgd2-5-hd.png"];
        }else{
            background = [CCSprite spriteWithFile:@"grating-bkgd2.png"];
        }
        
        //= [CCSprite spriteWithFile:@"grating-bkgd2.png"];
        background.anchorPoint = CGPointMake(0, 0);
        [self addChild: background z:1];

        // this will make the credits button go back to the main menu when touched.
        //CCMenuItemImage *m_credits = [CCMenuItemImage itemWithNormalImage:@"CreditsScreen.png" selectedImage:@"CreditsScreen.png" disabledImage:@"CreditsScreen.png" target:self selector:@selector(back:)];
        
        //m_menu = [CCMenu menuWithItems:m_credits, nil];
        
        CCSprite *m_credits = [CCSprite spriteWithFile:@"CreditsScreen.png"];
        [m_credits setPosition:CGPointMake(winSize.width * 0.5f, winSize.height*0.5)];
        
        [self addChild:m_credits z:2];
		//[self addChild:m_menu z:2];
        
        // the back button
        /*CCMenuItemImage *backButton = [CCMenuItemImage itemWithNormalImage:@"back_button2.png" selectedImage:@"back_button2.png" disabledImage:@"back_button2.png" target:self selector:@selector(back:)];
        backButton.position = ccp(winSize.width * 0.90f, winSize.height -75);
        [self addChild:backButton z:8];*/

        
        // the back button
        CCMenuItemImage *backButton = [CCMenuItemImage itemWithNormalImage:@"back_button2.png" selectedImage:@"back_button2_over.png" disabledImage:@"back_button2.png" target:self selector:@selector(back:)];
        
        CCMenu *_backmenu = [CCMenu menuWithItems:backButton, nil];
        if(winSize.width == 568){ //iPhone 5 resolution
            [_backmenu setPosition:ccp(winSize.width * 0.84f, winSize.height -75)];
        }
        else{ // iPhone 4s and whatever
            [_backmenu setPosition:ccp(winSize.width * 0.90f, winSize.height -75)];
        }
        //NSLog(@"SCREEN WIDTH: %f", winSize.width);
        [self addChild:_backmenu z:8];
        
		
	}
    
    return self;
}

-(void) back:(id) sender{
    
    //[[IAdHelper sharedInstance] moveBannerOffScreen];
    
    [SceneManager gotoMenu];
}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //UITouch *touch = [touches anyObject];
    
    NSLog(@"Go to Main Menu.");
    
    [SceneManager gotoMenu];
}


@end
