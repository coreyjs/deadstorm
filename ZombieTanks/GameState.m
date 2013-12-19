//
//  GameState.m
//  ZombieTanks
//
//  Created by Corey Schaf on 8/5/12.
//
//

#import "GameState.h"
#import "GCDatabase.h"

@implementation GameState


@synthesize killed1000_c;
@synthesize killed5000_c;
@synthesize playedFor24Hours_c;
@synthesize playedFor12HoursWith75Accuracy_c;
@synthesize firstKill_g;
@synthesize killed200InGame_g;
@synthesize killed500InGame_g;
@synthesize killed200InGameNoMedkit_g;
@synthesize used20MedkitsInGame_g;
@synthesize pointsFiftyThousandInGame_g;
@synthesize pointsOneHundredThousandInGame_g;
@synthesize survived20SecondsWithNoDamage_g;
@synthesize fired2000BulletsInOneGame_g;
@synthesize killedOneHundredZombiesWithoutTilting_g;
@synthesize have100percentAccuracyFor3Minutes_g;
@synthesize kill2ZombiesWithOneBullet_g;
@synthesize pickupFirstMedKit_g;
@synthesize playOneCompleteGame_g;
@synthesize pickupMedkitWithFullHealth_g;
@synthesize getOneMillionPoints_c;
@synthesize getHalfMillionPoints_c;
@synthesize survivedFor30SecondsWithLessThan10Health_g;
@synthesize getFirstPointMultiplier_g;
@synthesize keepOver4xPointMultiplierOverMinute_g;
@synthesize keepOver4xPointMultiplierOver5Minutes_g;
@synthesize dieWithNoKills_g;
@synthesize survive15SecondsWithNoKill_g;
@synthesize pickUpFirstAmmoBox_g;

@synthesize achiementCount = m_iAchievementUnlockCount;

static GameState* sharedInstance = nil;

+(GameState*) sharedInstance{
    
    @synchronized([GameState class]){
        if(!sharedInstance){
            //sharedInstance = [loadData]
            sharedInstance = loadData(@"GameState");
            if(!sharedInstance){
                
                [[self alloc] init];
            }
        }
        
        return sharedInstance;
    }
    
    return nil;
}

+(id)alloc{
    @synchronized ( [GameState class] ){
        
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of the GameState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    
    return nil;
}

-(void) save{
    
    saveData(self, @"GameState");
}

-(void) encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeBool:killed1000_c forKey:@"killed1000_c"];
    [aCoder encodeBool:killed5000_c forKey:@"killed5000_c"];
    [aCoder encodeBool:playedFor24Hours_c forKey:@"playedFor24Hours_c"];
    [aCoder encodeBool:playedFor12HoursWith75Accuracy_c forKey:@"playedFor12HoursWith75Accuracy_c"];
    [aCoder encodeBool:firstKill_g forKey:@"firstKill_g"];
    [aCoder encodeBool:killed200InGame_g forKey:@"killed200InGame_g"];
    [aCoder encodeBool:killed500InGame_g forKey:@"killed500InGame_g"];
    [aCoder encodeBool:killed200InGameNoMedkit_g forKey:@"killed200InGameNoMedkit_g"];
    [aCoder encodeBool:used20MedkitsInGame_g forKey:@"used20MedkitsInGame_g"];
    [aCoder encodeBool:pointsFiftyThousandInGame_g forKey:@"pointsFiftyThousandInGame_g"];
    [aCoder encodeBool:pointsOneHundredThousandInGame_g forKey:@"pointsOneHundredThousandInGame_g"];
    [aCoder encodeBool:survived20SecondsWithNoDamage_g forKey:@"survived20SecondsWithNoDamage_g"];
    [aCoder encodeBool:fired2000BulletsInOneGame_g forKey:@"fired2000BulletsInOneGame_g"];
    [aCoder encodeBool:killedOneHundredZombiesWithoutTilting_g forKey:@"killedOneHundredZombiesWithoutTilting_g"];
    [aCoder encodeBool:have100percentAccuracyFor3Minutes_g forKey:@"have100percentAccuracyFor3Minutes_g"];
    [aCoder encodeBool:kill2ZombiesWithOneBullet_g forKey:@"kill2ZombiesWithOneBullet_g"];
    [aCoder encodeBool:pickupFirstMedKit_g forKey:@"pickupFirstMedKit_g"];
    [aCoder encodeBool:playOneCompleteGame_g forKey:@"playOneCompleteGame_g"];
    [aCoder encodeBool:pickupMedkitWithFullHealth_g forKey:@"pickupMedkitWithFullHealth_g"];
    [aCoder encodeBool:getOneMillionPoints_c forKey:@"getOneMillionPoints_c"];
    [aCoder encodeBool:getHalfMillionPoints_c forKey:@"getHalfMillionPoints_c"];
    [aCoder encodeBool:survivedFor30SecondsWithLessThan10Health_g forKey:@"survivedFor30SecondsWithLessThan10Health_g"];
    [aCoder encodeBool:getFirstPointMultiplier_g forKey:@"getFirstPointMultiplier_g"];
    [aCoder encodeBool:keepOver4xPointMultiplierOverMinute_g forKey:@"keepOver4xPointMultiplierOverMinute_g"];
    [aCoder encodeBool:keepOver4xPointMultiplierOver5Minutes_g forKey:@"keepOver4xPointMultiplierOver5Minutes_g"];
    [aCoder encodeBool:dieWithNoKills_g forKey:@"dieWithNoKills_g"];
    [aCoder encodeBool:survive15SecondsWithNoKill_g forKey:@"survive15SecondsWithNoKill_g"];
    [aCoder encodeBool:pickUpFirstAmmoBox_g forKey:@"pickUpFirstAmmoBox_g"];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    
    if( (self = [super init]) ){
        
        m_iAchievementUnlockCount = 0;
        
        killed1000_c = [aDecoder decodeBoolForKey:@"killed1000_c"];
        if(killed1000_c) m_iAchievementUnlockCount += 1;
        
         killed5000_c = [aDecoder decodeBoolForKey:@"killed5000_c"];
        if(killed5000_c) m_iAchievementUnlockCount += 1;
        
         playedFor24Hours_c = [aDecoder decodeBoolForKey:@"playedFor24Hours_c"];
        if(playedFor24Hours_c) m_iAchievementUnlockCount += 1;
        
         playedFor12HoursWith75Accuracy_c = [aDecoder decodeBoolForKey:@"playedFor12HoursWith75Accuracy_c"];
        if(playedFor12HoursWith75Accuracy_c) m_iAchievementUnlockCount += 1;
        
         firstKill_g = [aDecoder decodeBoolForKey:@"firstKill_g"];
        if(firstKill_g) m_iAchievementUnlockCount += 1;
        
         killed200InGame_g = [aDecoder decodeBoolForKey:@"killed200InGame_g"];
        if(killed200InGame_g) m_iAchievementUnlockCount += 1;
        
         killed500InGame_g = [aDecoder decodeBoolForKey:@"killed500InGame_g"];
        if(killed500InGame_g) m_iAchievementUnlockCount += 1;
        
         killed200InGameNoMedkit_g = [aDecoder decodeBoolForKey:@"killed200InGameNoMedkit_g"];
        if(killed200InGameNoMedkit_g) m_iAchievementUnlockCount += 1;
        
         used20MedkitsInGame_g = [aDecoder decodeBoolForKey:@"used20MedkitsInGame_g"];
        if(used20MedkitsInGame_g) m_iAchievementUnlockCount += 1;
        
         pointsFiftyThousandInGame_g = [aDecoder decodeBoolForKey:@"pointsFiftyThousandInGame_g"];
        if(pointsFiftyThousandInGame_g) m_iAchievementUnlockCount += 1;
        
         pointsOneHundredThousandInGame_g = [aDecoder decodeBoolForKey:@"pointsOneHundredThousandInGame_g"];
        if(pointsOneHundredThousandInGame_g) m_iAchievementUnlockCount += 1;
        
         survived20SecondsWithNoDamage_g = [aDecoder decodeBoolForKey:@"survived20SecondsWithNoDamage_g"];
        if(survived20SecondsWithNoDamage_g) m_iAchievementUnlockCount += 1;
        
         fired2000BulletsInOneGame_g = [aDecoder decodeBoolForKey:@"fired2000BulletsInOneGame_g"];
        if(fired2000BulletsInOneGame_g) m_iAchievementUnlockCount += 1;
        
         killedOneHundredZombiesWithoutTilting_g = [aDecoder decodeBoolForKey:@"killedOneHundredZombiesWithoutTilting_g"];
        if(killedOneHundredZombiesWithoutTilting_g) m_iAchievementUnlockCount += 1;
        
         have100percentAccuracyFor3Minutes_g = [aDecoder decodeBoolForKey:@"have100percentAccuracyFor3Minutes_g"];
        if(have100percentAccuracyFor3Minutes_g) m_iAchievementUnlockCount += 1;
        
         kill2ZombiesWithOneBullet_g = [aDecoder decodeBoolForKey:@"kill2ZombiesWithOneBullet_g"];
        if(kill2ZombiesWithOneBullet_g) m_iAchievementUnlockCount += 1;
        
         pickupFirstMedKit_g = [aDecoder decodeBoolForKey:@"pickupFirstMedKit_g"];
        if(pickupFirstMedKit_g) m_iAchievementUnlockCount += 1;
        
         playOneCompleteGame_g = [aDecoder decodeBoolForKey:@"playOneCompleteGame_g"];
        if(playOneCompleteGame_g) m_iAchievementUnlockCount += 1;
        
         pickupMedkitWithFullHealth_g = [aDecoder decodeBoolForKey:@"pickupMedkitWithFullHealth_g"];
        if(pickupMedkitWithFullHealth_g) m_iAchievementUnlockCount += 1;
        
         getOneMillionPoints_c = [aDecoder decodeBoolForKey:@"getOneMillionPoints_c"];
        if(getOneMillionPoints_c) m_iAchievementUnlockCount += 1;
        
         getHalfMillionPoints_c = [aDecoder decodeBoolForKey:@"getHalfMillionPoints_c"];
        if(getHalfMillionPoints_c) m_iAchievementUnlockCount += 1;
        
         survivedFor30SecondsWithLessThan10Health_g = [aDecoder decodeBoolForKey:@"survivedFor30SecondsWithLessThan10Health_g"];
        if(survivedFor30SecondsWithLessThan10Health_g) m_iAchievementUnlockCount += 1;
        
         getFirstPointMultiplier_g = [aDecoder decodeBoolForKey:@"getFirstPointMultiplier_g"];
        if(getFirstPointMultiplier_g) m_iAchievementUnlockCount += 1;
        
         keepOver4xPointMultiplierOverMinute_g = [aDecoder decodeBoolForKey:@"keepOver4xPointMultiplierOverMinute_g"];
        if(keepOver4xPointMultiplierOverMinute_g) m_iAchievementUnlockCount += 1;
        
         keepOver4xPointMultiplierOver5Minutes_g = [aDecoder decodeBoolForKey:@"keepOver4xPointMultiplierOver5Minutes_g"];
        if(keepOver4xPointMultiplierOver5Minutes_g) m_iAchievementUnlockCount += 1;
        
         dieWithNoKills_g = [aDecoder decodeBoolForKey:@"dieWithNoKills_g"];
        if(dieWithNoKills_g) m_iAchievementUnlockCount += 1;
        
         survive15SecondsWithNoKill_g = [aDecoder decodeBoolForKey:@"survive15SecondsWithNoKill_g"];
        if(survive15SecondsWithNoKill_g) m_iAchievementUnlockCount += 1;
        
         pickUpFirstAmmoBox_g = [aDecoder decodeBoolForKey:@"pickUpFirstAmmoBox_g"];
        if(pickUpFirstAmmoBox_g) m_iAchievementUnlockCount += 1;
        
    }
    
    return self;
}

@end
















