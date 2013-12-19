//
//  HUDLayer.m
//  Tanks
//
//  Created by Ray Wenderlich on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"

@interface HUDLayer()

-(void) pauseGame;
-(BOOL) isTouchForPause:(CGPoint)touchLocation;

@end

@implementation HUDLayer

- (id) init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        

        _hpLabel = [CCLabelTTF labelWithString:@"HP: " fontName:@"Times New Roman" fontSize:12];
        _hpLabel.position = ccp( winSize.width - (winSize.width*.07f), winSize.height - 20);
        
        [self addChild:_hpLabel z:1];
        
        _scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Times New Roman" fontSize:12];
        //_scoreLabel.position = ccp(winSize.width - (winSize.width * 0.25f), winSize.height - 20);
        
        if(winSize.width == 568){ //iPhone 5 resolution
            _scoreLabel.position = ccp(winSize.width - 104, winSize.height - 20);
        }
        else{ // iPhone 4s and whatever
            _scoreLabel.position = ccp(winSize.width - (winSize.width * 0.21f), winSize.height - 20);
        }
        
        [self addChild:_scoreLabel z:1];
        
        _hudLScoreLifeImage = [CCSprite spriteWithFile:@"HUD_Display.png"];
        //_hudLScoreLifeImage.position = CGPointMake(winSize.width - (winSize.width * 0.20f), winSize.height - (winSize.height * 0.055f));
        
        if(winSize.width == 568){ //iPhone 5 resolution
            _hudLScoreLifeImage.position = CGPointMake(winSize.width - 100, winSize.height - (winSize.height * 0.055f));
        }
        else{ // iPhone 4s and whatever
            _hudLScoreLifeImage.position = CGPointMake(winSize.width - (winSize.width * 0.19f), winSize.height - (winSize.height * 0.055f));
        }
        
        [self addChild:_hudLScoreLifeImage z:0];
                                            
        _gunLabel = [CCLabelBMFont labelWithString:@"normal" fntFile:@"planecrash_18_white.fnt"];
        _gunLabel.position = ccp( winSize.width - (winSize.width*.15f), winSize.height - 37);
        
        [self addChild:_gunLabel z:1];
        
        
    }
    
    return self;
    
}

- (void)setHp:(int)hp {
    // Definite fix for the HUD sometimes showing negative value for health
    if(hp >= 0){
        [_hpLabel setString:[NSString stringWithFormat:@"%i %%", hp]];
        // BLINK AND TURN RED
        if(hp <= 25){
            // MAKE RED
            _hpLabel.color = ccc3(255,0,0);
        }
        else{
            // BACK TO WHITE
            _hpLabel.color = ccc3(255,255,255);
        }
    }
    else{
        hp = 0;
        [_hpLabel setString:[NSString stringWithFormat:@"%i %%", hp]];
    }
}

- (void)setGunLabel:(NSString *)gunName {
    // Definite fix for the HUD sometimes showing negative value for health
    if(gunName != nil){
        [_gunLabel setString:gunName];
    }
    else{
        // oops so default
        [_gunLabel setString:@"normal"];
    }
}


-(void)setScore:(int)score{
    [_scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
}




@end
