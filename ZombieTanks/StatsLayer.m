//
//  CreditsLayer.m
//  ZombieTanks
//
//  Created by Corey Schaf on 6/28/12.
//  Updated by Mike Bielat on 7/13/2012. Added ability to go back to main menu from the credits screen.

//  TODO: Make the www.BlaqkSheep.com take you to our website?

//  Copyright (c) 2012 blaQk Sheep. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "StatsLayer.h"
#import "SceneManager.h"
#import "AppDelegate.h"
#import "GCHelper.h"
#import "DataSystemsManager.h"
//#import "IAdHelper.h"
#import "InAppDeadstormHelper.h"

@implementation StatsLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    	// 'layer' is an autorelease object.
	StatsLayer *layer = [[StatsLayer alloc] init];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
   	
	// return the scene
	return scene;
}

-(id) init{
    
    /*
     [[IAdHelper sharedInstance] moveBannerOnScreen];
    */

    //if( ![[InAppDeadstormHelper sharedHelper] productPurchased:kDeadStormRemoveAdsIdentifier] ){
    //    [[IAdHelper sharedInstance] moveBannerOnScreen];
    //}

    winSize = [[CCDirector sharedDirector] winSize];

    /*CCLabelBMFont *tlabel = [CCLabelBMFont labelWithString:@"Page 2" fntFile:@"planecrash_14_black-hd.fnt"];
    CCMenuItemLabel *titem = [CCMenuItemLabel itemWithLabel:tlabel target:self selector:@selector(testCallback:)];
    CCMenu *menu = [CCMenu menuWithItems: titem, nil]; menu.position = ccp(winSize.width/2, winSize.height/2);*/



    /*if( (self = [super init]) ){
        
        self.isTouchEnabled=YES;
        
        
        _creditsImage = [CCSprite spriteWithFile:@"CreditsScreen.png"];
        [_creditsImage setPosition:CGPointMake(winSize.width*0.5f, winSize.height*0.5f)];
        [self addChild:_creditsImage z:1];

    }*/
    
    //self = [super init];
	if( self = [super init] ){
        // this is the ground.
        CCSprite* background;//
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        if(winSize.width == 568){
            background = [CCSprite spriteWithFile:@"grating-bkgd2-5-hd.png"];
        }else{
            background = [CCSprite spriteWithFile:@"grating-bkgd2.png"];
        }
        background.anchorPoint = CGPointMake(0, 0);
        [self addChild: background z:1];
        
        // this will make the credits button go back to the main menu when touched.
        /*CCMenuItemImage *m_stats = [CCMenuItemImage itemWithNormalImage:@"MainMenuBackground.png" selectedImage:@"MainMenuBackground.png" disabledImage:@"MainMenuBackground.png" target:self selector:@selector(back:)];

        m_menu = [CCMenu menuWithItems:m_stats, nil];
        
		[self addChild:m_menu z:2];*/
        
        CCSprite *m_bkgd = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        [m_bkgd setPosition:CGPointMake(winSize.width * 0.5f, winSize.height*0.5)];
        
        [self addChild:m_bkgd z:2];
        
        [self ViewGameStats];
        
        CCSprite* highScoreImage = [CCSprite spriteWithFile:@"highScoreButton.png"];
        //highScoreImage.tag = 3;
        highScoreImage.position = ccp(winSize.width * 0.4f, winSize.height - 80);
        [self addChild: highScoreImage z:5];
        
        CCMenuItemImage *m_leaderboard = [CCMenuItemImage itemWithNormalImage:@"leaderboardsButton.png" selectedImage:@"leaderboardsButton.png" disabledImage:@"leaderboardsButton.png" target:self selector:@selector(leaderboards)];
        
        CCMenuItemImage *m_tweet = [CCMenuItemImage itemWithNormalImage:@"PostToTwitter.png" selectedImage:@"PostToTwitter_over.png" disabledImage:@"PostToTwitter.png" target:self selector:@selector(tweetScore:)];
        
        CCMenuItemImage *m_achievements = [CCMenuItemImage itemWithNormalImage:@"achievementsButton.png" selectedImage:@"achievementsButton.png" disabledImage:@"achievementsButton.png" target:self selector:@selector(showAchievements)];
		
        //CCMenu *_menu = [CCMenu menuWithItems: m_leaderboard, m_tweet, m_achievements, nil];
        CCMenu *_menu = [CCMenu menuWithItems: m_tweet, nil];
        [_menu alignItemsHorizontallyWithPadding:5];
		[_menu setPosition:ccp(winSize.width/2, winSize.height/2 - 95)];
        [self addChild:_menu z:6];
        
        // the back button
        CCMenuItemImage *backButton = [CCMenuItemImage itemWithNormalImage:@"back_button2.png" selectedImage:@"back_button2_over.png" disabledImage:@"back_button2.png" target:self selector:@selector(back:)];
        
        CCMenu *_backmenu = [CCMenu menuWithItems:backButton, nil];
        
        if(winSize.width == 568){ //iPhone 5 resolution
            [_backmenu setPosition:ccp(winSize.width * 0.84f, winSize.height -75)];
        }
        else{ // iPhone 4s and whatever
            [_backmenu setPosition:ccp(winSize.width * 0.90f, winSize.height -75)];
        }

        [self addChild:_backmenu z:8];
        
        //backButton.position = ccp(winSize.width * 0.90f, winSize.height -75);
        //[self addChild:backButton z:8];

	}
    
    return self;
}

-(void)leaderboards{
    // allow for muiltpile types of leaderboard querying
    [[GCHelper sharedInstance] showLeaderboard];
}

-(void) tweetScore:(id)sender{
    
    DataSystemsManager *m_dataManager = [DataSystemsManager getDataSystemsManager];
  
    //[m_dataManager tweetMessage];
    
    // format message
   // NSString *_msg = stats, _totalZombiesKilled];
    NSString *_msg = @"PUT ALL STATS HERE";
    [m_dataManager tweetMessage:_tweetMessage];
    
}

-(void) ViewGameStats{
    ///////////////////////////////////////////////////////////////////////////
    // SAVE GAME DATA TO DEVICE
    ///////////////////////////////////////////////////////////////////////////
    // FIRST RETRIEVE GAME DATA FROM THE DEVICE
    ///////////////////////////////////////////////////////////////////////////
    int tempTotalShotsFired = 0;
    int tempTotalKillCount = 0;
    int tempTotalScore = 0;
    float tempTotalGameTime = 0;
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TotalShotsFired"] == nil){
        tempTotalShotsFired = 0;
    }
    else{
        tempTotalShotsFired = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalShotsFired"];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TotalKillCount"] == nil){
        tempTotalKillCount = 0;
    }
    else{
        tempTotalKillCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalKillCount"];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TotalScore"] == nil){
        tempTotalScore = 0;
    }
    else{
        tempTotalScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalScore"];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TotalGameTime"] == nil){
        tempTotalGameTime = 0;
    }
    else{
        tempTotalGameTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalGameTime"];
    }
    
    NSMutableArray *highScoreArray = [[NSMutableArray alloc] initWithCapacity:11];
    
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"HighScores"] == nil){
        // first time playing?
        NSLog(@"NO PREVIOUS HIGH SCORES... CREATE NEW ONES");
        highScoreArray= [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil];
    }
    else{
        highScoreArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"HighScores"];
    }
    
    // build the intro screen we see when
    // we first begin the game
    //CCLayerColor *_highScoreImage = [CCLayerColor layerWithColor:ccc4(1,1,1,1)];
    //CCSprite *m_highSCoreSprite = [CCSprite spriteWithFile:@"highScoreButton.png"];
    //[m_highSCoreSprite setPosition:CGPointMake(winSize.width * 0.5f, winSize.height*0.5)];
    //[_highScoreImage addChild:m_highSCoreSprite z:250];
    //[self addChild:_highScoreImage z:250];
    
    NSString *highScore1Str = [NSString stringWithFormat:@"%i",[[highScoreArray objectAtIndex:0] intValue]];
    
    //CCLabelTTF *_score1 = [CCLabelTTF labelWithString:highScore1Str fontName:@"Times New Roman" fontSize:18];
    CCLabelBMFont *_score1 = [CCLabelBMFont labelWithString:highScore1Str fntFile:@"planecrash_24_black.fnt"];
    _score1.position = CGPointMake( (winSize.width * 0.51f ) , (winSize.height - (winSize.height *.3) ));
    //_score1.color = ccc3(0,0,0);
    [self addChild:_score1 z:201];
    
    /////////////////////////////
    
    NSString *highScore2Str = [NSString stringWithFormat:@"2nd highest: %i",[[highScoreArray objectAtIndex:1] intValue]];
    
    //CCLabelTTF *_score2 = [CCLabelTTF labelWithString:highScore2Str fontName:@"Times New Roman" fontSize:12];
    CCLabelBMFont *_score2 = [CCLabelBMFont labelWithString:highScore2Str fntFile:@"planecrash_18_black.fnt"];
    
    _score2.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.35) ));
    _score2.color = ccc3(0,0,0);
    [self addChild:_score2 z:201];
    
    /////////////////////////////
    
    NSString *highScore3Str = [NSString stringWithFormat:@"3rd highest: %i",[[highScoreArray objectAtIndex:2] intValue]];
    
    //CCLabelTTF *_score3 = [CCLabelTTF labelWithString:highScore3Str fontName:@"Times New Roman" fontSize:12];
    
    CCLabelBMFont *_score3 = [CCLabelBMFont labelWithString:highScore3Str fntFile:@"planecrash_18_black.fnt"];
    _score3.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.4) ));
    _score3.color = ccc3(0,0,0);
    [self addChild:_score3 z:201];
    
    /////////////////////////////
    
    NSString *highScore4Str = [NSString stringWithFormat:@"4th highest: %i",[[highScoreArray objectAtIndex:3] intValue]];
    
   // CCLabelTTF *_score4 = [CCLabelTTF labelWithString:highScore4Str fontName:@"Times New Roman" fontSize:12];
    
    CCLabelBMFont *_score4 = [CCLabelBMFont labelWithString:highScore4Str fntFile:@"planecrash_18_black.fnt"];
    _score4.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.45) ));
    _score4.color = ccc3(0,0,0);
    [self addChild:_score4 z:201];
    
    /////////////////////////////
    
    NSString *highScore5Str = [NSString stringWithFormat:@"5th highest: %i",[[highScoreArray objectAtIndex:4] intValue]];
    
    //CCLabelTTF *_score5 = [CCLabelTTF labelWithString:highScore5Str fontName:@"Times New Roman" fontSize:12];
    
    CCLabelBMFont *_score5 = [CCLabelBMFont labelWithString:highScore5Str fntFile:@"planecrash_18_black.fnt"];
    _score5.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.5) ));
    _score5.color = ccc3(0,0,0);
    [self addChild:_score5 z:201];

    ///////////////////////////////
    ///////////////////////////////
    ///////////////////////////////
    // TOTAL SHOTS FIRED
    NSString *shotsFiredStr = [NSString stringWithFormat:@"total shots fired: %i", tempTotalShotsFired];
    
   // CCLabelTTF *_shotsFired = [CCLabelTTF labelWithString:shotsFiredStr fontName:@"Times New Roman" fontSize:14];
    
    CCLabelBMFont *_shotsFired = [CCLabelBMFont labelWithString:shotsFiredStr fntFile:@"planecrash_14_black.fnt"];
    _shotsFired.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.58) ));
    _shotsFired.color = ccc3(0,0,0);
    [self addChild:_shotsFired z:201];
    
    ///////////////////////////////
    // TOTAL ZOMBIES KILLED
    NSString *killCountStr = [NSString stringWithFormat:@"total zombies killed: %i", tempTotalKillCount];
    
    //CCLabelTTF *_killCount = [CCLabelTTF labelWithString:killCountStr fontName:@"Times New Roman" fontSize:14];
    
    CCLabelBMFont *_killCount = [CCLabelBMFont labelWithString:killCountStr fntFile:@"planecrash_14_black.fnt"];
    _killCount.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.62) ));
    _killCount.color = ccc3(0,0,0);
    [self addChild:_killCount z:201];
    
    ///////////////////////////////
    // TOTAL TIME PLAYED
    int tempTime2 = tempTotalGameTime;
    int days2 = tempTime2 / (60 * 60 * 24);
    tempTime2 -= days2 * (60 * 60 * 24);
    
    int hours2 = (tempTime2 / (60 * 60));
    tempTime2 -= hours2 * (60 * 60);
    int minutes2 = (tempTime2 / 60);
    
    tempTime2 -= minutes2 * 60;
    int seconds2 = tempTime2;

    NSString *timeStr = [NSString stringWithFormat:@"total time played: %02i:%02i:%02i", hours2, minutes2, seconds2];
    
    //CCLabelTTF *_time = [CCLabelTTF labelWithString:timeStr fontName:@"Times New Roman" fontSize:14];
    
    CCLabelBMFont *_time = [CCLabelBMFont labelWithString:timeStr fntFile:@"planecrash_14_black.fnt"];
    _time.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.66) ));
    _time.color = ccc3(0,0,0);
    [self addChild:_time z:201];
    
    ///////////////////////////////
    // TOTAL SCORE 
    NSString *scoreStr = [NSString stringWithFormat:@"accumulated score: %i", tempTotalScore];
    
    //NSString *scoreStr = [NSString stringWithFormat:@"w", tempTotalScore];
    //CCLabelTTF *_score = [CCLabelTTF labelWithString:scoreStr fontName:@"Times New Roman" fontSize:14];
    CCLabelBMFont *_score = [CCLabelBMFont labelWithString:scoreStr fntFile:@"planecrash_14_black.fnt"];
    _score.position = CGPointMake( (winSize.width * 0.5f ) , (winSize.height - (winSize.height *.7) ));
    _score.color = ccc3(0,0,0);
    [self addChild:_score z:201];
    
    //////////////////////////////////////
    // TO DO: XXXXX
    // ADD TWEET, GAME CENTER, LEADERBOARD / ACHIEVEMENTS
    // STYLE NICER
    //////////////////////////////////////
    
    _tweetMessage = [NSString stringWithFormat:@"I've killed %i zombies with a total score of %i in #Deadstorm @DeadstormGame - http://tinyurl.com/deadstorm",
                     tempTotalKillCount, tempTotalScore];
    
    
}

-(void) back:(id) sender{
    // [[IAdHelper sharedInstance] moveBannerOffScreen];
    [SceneManager gotoMenu];
}

-(void) store:(id)sender{
    
    [SceneManager gotoStore];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //UITouch *touch = [touches anyObject];
    
    NSLog(@"Go to Main Menu.");
    
    [SceneManager gotoMenu];
}

#pragma mark internal methods

-(void) showAchievements{
    CCLOG(@"Show Achievements");
 
  //  [gkHelper showAchievements];
    
    [[GCHelper sharedInstance] showAchievements];
    
//    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
//    
//    if(achievements != NULL){
//        achievements.achievementDelegate = self;
//        [delegate.viewController presentModalViewController:achievements animated:YES];
//    }
    
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
    
   // AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //[delegate.viewController di]
}


@end
