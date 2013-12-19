//
//  AppDelegate.h
//  ZombieTanks
//
//  Created by Corey Schaf on 1/26/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate> {
	UIWindow			*window_;
	RootViewController	*viewController_;
    CCDirectorIOS	*director_;					// weak ref XXXXX MAB from cocos2d project
    UINavigationController *navController;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) RootViewController *viewController;
@property (readonly) CCDirectorIOS *director;
@property (readonly) UINavigationController *navController;

@end
