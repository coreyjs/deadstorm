//
//  TransitionLayer.m
//  ZombieTanks
//
//  Created by Corey Schaf on 8/27/12.
//
//

#import "TransitionLayer.h"
#import "MenuScene.h"

@implementation TransitionLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TransitionLayer *layer = [TransitionLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)onEnter{
    
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]];
}

@end
