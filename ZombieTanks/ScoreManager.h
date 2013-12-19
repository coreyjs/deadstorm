//
//  ScoreManager.h
//  ZombieTanks
//
//  Created by Corey Schaf on 7/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"

// we subclass CCNode so we can add directly as a child to gamescene
@interface ScoreManager : CCNode {
    
CCLabelTTF * _score;
    
}


@end
