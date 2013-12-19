//
//  BannerLayer.h
//  ZombieTanks
//
//  Created by Michael Bielat on 12/30/12.
//  This will pop up an annoying-ish ad banner asking player to buy the nuke
//

#import "cocos2d.h"
#import "CCLayer.h"

@interface BannerLayer : CCLayer{
    
    CCSprite *_backgroundImage;
    CCMenu *_menu;
}

+(id)scene;

@end

