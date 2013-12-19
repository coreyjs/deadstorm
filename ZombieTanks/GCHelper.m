//
//  GCHelper.m
//  ZombieTanks
//
//  Created by Corey Schaf on 8/4/12.
//
//

#import "GCHelper.h"
#import "GCDatabase.h"
#import "cocos2d.h"
#import "AppDelegate.h"

@implementation GCHelper

@synthesize achievementsToReport = _achievementsToReport;
@synthesize scoresToReport = _scoresToReport;

#pragma mark Loading/Saving

static GCHelper *sharedHelper = nil;

+(GCHelper *) sharedInstance{
    
    @synchronized([GCHelper class]){
        if(!sharedHelper){
            
            sharedHelper = loadData(@"GameCenterData");
            if(!sharedHelper){
                [[self alloc] initWithScoresToReport:[NSMutableArray array] achievementsToReport:[NSMutableArray array]];
            }
        }
        
        return sharedHelper;
    }
    
    return nil;
}

+(id) alloc{
    @synchronized([GCHelper class]){
        NSAssert(sharedHelper == nil, @"Attempted to allocate a second instance of the GCHelper singleton");
        
        sharedHelper = [super alloc];
        
        return sharedHelper;
    }
    
    return nil;
}

-(BOOL) isGameCenterAvailable{
    
    //check for presence of GKLocalPlayer API
    
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running ios 4.1 or later
    NSString *regSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:regSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

-(id) initWithScoresToReport:(NSMutableArray *)scoresToReport achievementsToReport:(NSMutableArray *)achievements{
    
    if((self = [super init])){
        
        self.scoresToReport = scoresToReport;
        self.achievementsToReport = achievements;
        
        gameCenterAvailable = [self isGameCenterAvailable];
        if(gameCenterAvailable){
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    
    return self;

}

#pragma mark Internal functions

-(void) authenticationChanged{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if([GKLocalPlayer localPlayer].isAuthenticated &&
           !userAuthenticated){
            NSLog(@"Authentication changed: player authenticated.");
            userAuthenticated = TRUE;
            [self resendData];
        }else if(![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated){
            NSLog(@"Authentication changed: player not authenticated");
            userAuthenticated = FALSE;
        }
    });
}

-(void)sendScore:(GKScore *) score{
    
    [score reportScoreWithCompletionHandler:^(NSError *error){
       
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if(error == NULL){
                NSLog(@"Sussesfully sent scores!");
            }else{
                NSLog(@"Score failed to send...will try again later. Reason %@ ", error.localizedDescription);
            }
        });
        
    }];
}

-(void) sendAchievement:(GKAchievement *)achievment{
    [achievment reportAchievementWithCompletionHandler:
     ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if( error == NULL){
                NSLog(@"Successfully sent achievment!");
                [_achievementsToReport removeObject:achievment];
            }else{
                NSLog(@"achievement failed to send... wil try again later. Reason %@", error.localizedDescription);
            }
        });
     }];
}

-(void) resendData{
    
    for(GKAchievement *achievment in _achievementsToReport){
        [self sendAchievement:achievment];
    }
    
    for(GKScore *score in _scoresToReport){
        [self sendScore:score];
    }
}

#pragma mark User functions
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] \
compare:v options:NSNumericSearch] == NSOrderedAscending)

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController {
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc {
    UIViewController* rootVC = [self getRootViewController];
    if([rootVC shouldAutorotate]){
    [rootVC presentViewController:vc animated:YES
                       completion:nil];
    }
}

-(void) authenticateLocalUser{
    
    if(!gameCenterAvailable) return;
    
    NSLog(@"Authentication local user...");
    if([GKLocalPlayer localPlayer].isAuthenticated == NO){
        if (SYSTEM_VERSION_LESS_THAN(@"6.0")){
            // ios 5.x and below
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
           // [[GKLocalPlayer localPlayer] setAuthenticate ]
        }
        else{
            GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

            localPlayer.authenticateHandler =
            ^(UIViewController *viewController,
              NSError *error) {
                
               // [self setLastError:error];
                
                if ([CCDirector sharedDirector].isPaused)
                    [[CCDirector sharedDirector] resume];
                
                if (localPlayer.authenticated) {
                    //_gameCenterFeaturesEnabled = YES;
                } else if(viewController) {
                    [[CCDirector sharedDirector] pause];
                    ////////////////////////////////////////
                    ////////////////////////////////////////
                    // IOS 6 BUG PREVENTS GAME CENTER LOGIN VIEW FROM BEING PORTRAIT ONLY AND NOT LANDSCAPE. COMMENTING OUT NOW.
                    [self presentViewController:viewController];  // show the view controller
                    ////////////////////////////////////////
                    ////////////////////////////////////////
                } else {
                   // _gameCenterFeaturesEnabled = NO;
                }
            };
            
            //            [localPlayer setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {
//                /*if (viewController != nil) {
//                    [self presentViewController:viewController animated:YES completion:nil];
//                } else 
//                 */
//                
//                if(viewController){
//                [[UIApplication
//                  sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
//                }
//                if (localPlayer.isAuthenticated) {
//                    // do post-authentication work
//                    [self presentViewController:viewController];
//                    CCLOG(@"PLAYER LOGGED IN");
//                } else {
//                    // do unauthenticated work, such as error message, etc
//                    CCLOG(@"Authentication Error = %s", error);
//                }
//               
//            }];
            

        }
        /*else {
            
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Game Center"
                                      message:@"You're not logged into Game Center."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            
        }*/
    }else{
        NSLog(@"Already authenticated");
    }
}

-(void) save{
    
    saveData(self, @"GameCenterData");
}

-(void) reportScore:(NSString *)identifier score:(int)score{
    
    GKScore *gScore = [[GKScore alloc] initWithCategory:identifier];
    gScore.value = score;
    [_scoresToReport addObject:gScore];
    [self save];
    
    if(!gameCenterAvailable || !userAuthenticated){
        return;
    }
    
    [self sendScore:gScore];
}

-(void) reportAchievement:(NSString *)identifier percentComplete:(double)percentComplete{
    
    GKAchievement *achievment = [[GKAchievement alloc] initWithIdentifier:identifier];
    
    achievment.percentComplete = percentComplete;
    achievment.showsCompletionBanner = YES;
    [_achievementsToReport addObject:achievment];
    [self save];
    
    if(!gameCenterAvailable || !userAuthenticated) return;
    [self sendAchievement:achievment];
    
    //GKNotificationBanner *banner = [[GKNotificationBanner alloc] s
//    [GKNotificationBanner showBannerWithTitle:@"Unlocked!" message:achievment. completionHandler:^(void){
//        
//    }];

}

#pragma mark NSCoding

-(void) encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_scoresToReport forKey:@"ScoresToReport"];
    [encoder encodeObject:_achievementsToReport forKey:@"AchievementsToReport"];
}

-(id) initWithCoder:(NSCoder*) decoder{
    
    NSMutableArray *theAchievementsToReport = [decoder decodeObjectForKey:@"AchievementsToReport"];
    NSMutableArray *theScoresToReport = [decoder decodeObjectForKey:@"ScoresToRepor"];
    
    return [self initWithScoresToReport:theScoresToReport achievementsToReport:theAchievementsToReport];
}

-(void) showLeaderboard
{
	if (gameCenterAvailable == NO)
		return;
	
	GKLeaderboardViewController* leaderboardVC = [[GKLeaderboardViewController alloc] init];
	if (leaderboardVC != nil)
	{
		AppDelegate *delegate = [UIApplication sharedApplication].delegate;
		leaderboardVC.leaderboardDelegate = self;
        
        
        //UIViewController *cont = delegate.viewController;
        
        UIViewController *cont = [[CCDirector sharedDirector] navigationController];
        leaderboardVC.category = kLeaderboardHighScore;
        leaderboardVC.timeScope = GKLeaderboardTimeScopeAllTime;
        [cont presentModalViewController:leaderboardVC animated:YES];
        
	}
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //UIViewController *cont = delegate.viewController;
    UIViewController *cont = [[CCDirector sharedDirector] navigationController];
    [cont dismissModalViewControllerAnimated:YES];
}

// Achievements

-(void) showAchievements
{
	if (gameCenterAvailable == NO)
		return;
	
	GKAchievementViewController* achievementsVC = [[GKAchievementViewController alloc] init];
	if (achievementsVC != nil)
	{
     
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
		achievementsVC.achievementDelegate = self;
        
        
        //UIViewController *cont = delegate.viewController;
        UIViewController *cont = [[CCDirector sharedDirector] navigationController];
        
        
        [cont presentModalViewController:achievementsVC animated:YES];
        //[achievementsVC dis]
		//[view presentViewController:achievementsVC];
        
	}
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
	//[self dismissModalViewController];
	//[delegate onAchievementsViewDismissed];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //UIViewController *cont = delegate.viewController;
    UIViewController *cont = [[CCDirector sharedDirector] navigationController];
    [cont dismissModalViewControllerAnimated:YES];
    
    
}


//-(UIViewController*) getRootViewController
//{
//	return [UIApplication sharedApplication].keyWindow.rootViewController;
//}
//
//-(void) presentViewController:(UIViewController*)vc
//{
//	UIViewController* rootVC = [self getRootViewController];
//	//[rootVC presentModalViewController:vc animated:YES];
//    //[[rootVC preferredInterfaceOrientationForPresentation]
//    //rootVC.modalInPopover = YES;
//    //rootVC.p
//    [rootVC presentViewController:vc animated:YES completion:^(void){}];
//}

-(void) dismissModalViewController
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC dismissModalViewControllerAnimated:YES];
    [rootVC dismissViewControllerAnimated:YES completion:^(void){}];
}

@end














