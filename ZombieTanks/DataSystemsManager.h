//
//  DataSystemsManager.h
//  ZombieTanks
//
//  Created by Corey Schaf on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// This class will handle the talking to and from the device
// for saving data and accessing social networks


#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import "cocos2d.h"



@interface DataSystemsManager : NSObject{
    
    UIViewController *viewController;
}

@property (nonatomic, retain) UIViewController *viewController;

+(DataSystemsManager *) getDataSystemsManager;

-(void) loadHiScores;
-(void) addHiScore;
-(void) tweetMessage;
-(void) tweetMessage:(NSString*) message;

@end
