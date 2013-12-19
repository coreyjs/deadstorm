//
//  HUDLayer.h
//  Tanks
//
//  Created by Ray Wenderlich on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface HUDLayer : CCLayer {
    CCLabelTTF * _hpLabel;
    CCLabelBMFont * _gunLabel;
    CCLabelTTF *_scoreLabel;

    
    // maybe move to sprite batch later on for performance
    CCSprite *_hudLScoreLifeImage;
}

- (void)setHp:(int)hp;
- (void)setScore:(int)score;
- (void)setGunLabel:(NSString *)gunName;

+(CGPoint) locationFromTouch:(UITouch *)touch;

@end
