//
//  GameState.h
//  ZombieTanks
//
//  Created by Corey Schaf on 8/5/12.
//
//

#import <Foundation/Foundation.h>



@interface GameState : NSObject <NSCoding> {
    
    // handle each achievemnt here
    BOOL killed1000_c;
    BOOL killed5000_c;
    BOOL playedFor24Hours_c;
    BOOL playedFor12HoursWith75Accuracy_c;
    BOOL firstKill_g;
    BOOL killed200InGame_g;
    BOOL killed500InGame_g;
    BOOL killed200InGameNoMedkit_g;
    BOOL used20MedkitsInGame_g;
    BOOL pointsFiftyThousandInGame_g;
    BOOL pointsOneHundredThousandInGame_g;
    BOOL survived20SecondsWithNoDamage_g;
    BOOL fired2000BulletsInOneGame_g;
    BOOL killedOneHundredZombiesWithoutTilting_g;
    BOOL have100percentAccuracyFor3Minutes_g;
    BOOL kill2ZombiesWithOneBullet_g;
    BOOL pickupFirstMedKit_g;
    BOOL playOneCompleteGame_g;
    BOOL pickupMedkitWithFullHealth_g;
    BOOL getOneMillionPoints_c;
    BOOL getHalfMillionPoints_c;
    BOOL survivedFor30SecondsWithLessThan10Health_g;
    BOOL getFirstPointMultiplier_g;
    BOOL keepOver4xPointMultiplierOverMinute_g;
    BOOL keepOver4xPointMultiplierOver5Minutes_g;
    BOOL dieWithNoKills_g;
    BOOL survive15SecondsWithNoKill_g;
    BOOL pickUpFirstAmmoBox_g;
    
    int m_iAchievementUnlockCount;
    
    NSMutableArray *m_scoresToReport;
    NSMutableArray *m_achievementsToReport;
}

+(GameState *) sharedInstance;
-(void) save;
-(id) initWithScoresToReport:(NSMutableArray *) scoresToReport achievementsToReport:(NSMutableArray *) achievementsToReport;



@property (assign) BOOL killed1000_c;
@property (assign) BOOL killed5000_c;
@property (assign) BOOL playedFor24Hours_c;
@property (assign) BOOL playedFor12HoursWith75Accuracy_c;
@property (assign) BOOL firstKill_g;
@property (assign) BOOL killed200InGame_g;
@property (assign) BOOL killed500InGame_g;
@property (assign) BOOL killed200InGameNoMedkit_g;
@property (assign) BOOL used20MedkitsInGame_g;
@property (assign) BOOL pointsFiftyThousandInGame_g;
@property (assign) BOOL pointsOneHundredThousandInGame_g;
@property (assign) BOOL survived20SecondsWithNoDamage_g;
@property (assign) BOOL fired2000BulletsInOneGame_g;
@property (assign) BOOL killedOneHundredZombiesWithoutTilting_g;
@property (assign) BOOL have100percentAccuracyFor3Minutes_g;
@property (assign) BOOL kill2ZombiesWithOneBullet_g;
@property (assign) BOOL pickupFirstMedKit_g;
@property (assign) BOOL playOneCompleteGame_g;
@property (assign) BOOL pickupMedkitWithFullHealth_g;
@property (assign) BOOL getOneMillionPoints_c;
@property (assign) BOOL getHalfMillionPoints_c;
@property (assign) BOOL survivedFor30SecondsWithLessThan10Health_g;
@property (assign) BOOL getFirstPointMultiplier_g;
@property (assign) BOOL keepOver4xPointMultiplierOverMinute_g;
@property (assign) BOOL keepOver4xPointMultiplierOver5Minutes_g;
@property (assign) BOOL dieWithNoKills_g;
@property (assign) BOOL survive15SecondsWithNoKill_g;
@property (assign) BOOL pickUpFirstAmmoBox_g;

@property (assign) int achiementCount;
@end
