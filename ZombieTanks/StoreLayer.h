//
//  StoreLayer.h
//  ZombieTanks
//
//  Created by Corey Schaf on 11/9/12.
//
//

#import "cocos2d.h"

@interface StoreLayer : CCLayer{
    
    CCSprite *_backgroundImage;
    CCMenu *_menu;
}

+(id)scene;

@end
