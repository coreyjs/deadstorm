//
//  ABGameKitHelper.h
//  Pastry Panic
//
//  Created by Alexander Blunck on 27.02.12.
//  Copyright (c) 2012 Ablfx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kLeaderboardHighScore @"com.blaqksheep.deadstorm.highscores"
#define kLeaderboardKills @"com.blaqksheep.deadstorm.mostkills"

#define kKilled1000_c @"com.blaqksheep.deadstorm.killed1000_c"
#define kKilled5000_c @"om.blaqksheep.deadstorm.killed5000_c"
#define kPlayedFor24Hours_c @"com.blaqksheep.deadstorm.playedfor24hours_c"
#define kPlayedFor12HoursWith75Accuracy_c @"com.blaqksheep.deadstorm.playedfor24hours75accuracy_c"
#define kFirstKill_g @"com.blaqksheep.deadstorm.firstkill_g"
#define kKilled200InGame_g @"com.blaqksheep.deadstorm.twohundredkills_g"
#define kKilled500InGame_g @"com.blaqksheep.deadstorm.fivehundredkills_g"
#define kKilled200InGameNoMedkit_g @"com.blaqksheep.deadstorm.killedtwohundrednomedkit_g"
#define kUsed20MedkitsInGame_g @"com.blaqksheep.deadstorm.use20medkits_g"
#define kPointsFiftyThousandInGame_g @"com.blaqksheep.deadstorm.fiftythousandpoints_g"
#define kPointsOneHundredThousandInGame_g @"com.blaqksheep.deadstorm.onehundredthousandpoints_g"
#define kSurvived20SecondsWithNoDamage_g @"com.blaqksheep.deadstorm.twentysecondsnodamage_g"
#define kFired2000BulletsInOneGame_g @"com.blaqksheep.deadstorm.fired2000bullets_g"
//#define kKilledOneHundredZombiesWithoutTilting_g @"com.blaqksheep.deadstorm."
//#define kHave100percentAccuracyFor3Minutes_g @"com.blaqksheep.deadstorm."
//#define kKill2ZombiesWithOneBullet_g @"com.blaqksheep.deadstorm."
#define kPickupFirstMedKit_g @"com.blaqksheep.deadstorm.firstmedkit_g"
#define kPlayOneCompleteGame_g @"com.blaqksheep.deadstorm.firstgame_g"
#define kPickupMedkitWithFullHealth_g @"com.blaqksheep.deadstorm.medkitwithfullhealth_g"
#define kGetOneMillionPoints_c @"com.blaqksheep.deadstorm.onemillionpoints_c"
#define kGetHalfMillionPoints_c @"com.blaqksheep.deadstorm.halfmillionpoints_c"
#define kSurvivedFor30SecondsWithLessThan10Health_g @"com.blaqksheep.deadstorm.survive30seconds10health_g"
#define kGetFirstPointMultiplier_g @"com.blaqksheep.deadstorm.firstpointmultiplier_g"
//#define kKeepOver4xPointMultiplierOverMinute_g @"com.blaqksheep.deadstorm."
//#define kKeepOver4xPointMultiplierOver5Minutes_g @"com.blaqksheep.deadstorm."
#define kDieWithNoKills_g @"com.blaqksheep.deadstorm.nokills_g"
#define kSurvive15SecondsWithNoKill_g @"com.blaqksheep.deadstorm.survive15secondsnokill_g"
#define kPickUpFirstAmmoBox_g @"com.blaqksheep.deadstorm.pickupfirstammo_g"

@interface ABGameKitHelper : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>

@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic) BOOL isActivated;

+ (id)sharedClass;

-(void) authenticatePlayer;
-(void) showAchievements;
-(void) showLeaderboard:(NSString*)leaderboardID;
-(void) reportScore:(int)score forLeaderboard:(NSString*)leaderboardName;
-(void) reportAchievement:(NSString*)identifier percentComplete:(float)percent;

-(void) resetAchievements;

-(void) showNotification:(NSString*)title message:(NSString*)message identifier:(NSString*)identifier;

@end
