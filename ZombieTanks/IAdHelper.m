//
//  IAdHelper.m
//  ZombieTanks
//
//  Created by Corey Schaf on 10/9/12.
//
//

//#import "IAdHelper.h"
/*
#import "cocos2d.h"

@implementation IAdHelper

@synthesize bannerView;

+ (IAdHelper *) sharedInstance
{
    static IAdHelper *sharedHelper;
    
    if (!sharedHelper)
    {
        sharedHelper = [[self alloc] init];
    }
    return sharedHelper;
}

-(void) createAdView //Main method to create a view
{
    static NSString * const kADBannerViewClass = @"ADBannerView";
    
    if (NSClassFromString(kADBannerViewClass) != nil)
    {
        
        self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(50, 200, 100, 100)];
        
        [self.bannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifierLandscape,nil]];
        
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        
        [self.bannerView setDelegate:self];
        
        [navController.view addSubview:self.bannerView];
        
        //[self moveBannerOffScreen];
    }
    
}

//Will be called after Banner is loaded succesfully ( check moveBannerOffScreen)
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //[self moveBannerOnScreen];
    [self moveBannerOffScreen];
}

//First move the banner out of the screen until it is loaded fully (apple required, no white banner space)
-(void) moveBannerOffScreen
{
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
#warning The size of the ads needs to be used according iphone or ipad
    self.bannerView.frame = CGRectMake(0, (-1) * windowSize.height, 320, 50); //size of the banner need to change
    NSLog(@"Banner moved out of the screen");
}
/*
//Move the banner on to the screen
-(void) moveBannerOnScreen
{
    /*
    [UIView beginAnimations:@"BannerViewIntro" context:NULL];
    //self.bannerView.frame = CGRectZero; // same as CGRectMake(0,0,0,0)
    self.bannerView.frame = CGRectMake(50, 0, 100, 100);  // MAB fixed so it is off screen some
    //self.bannerView.frame=CGRectMake(0.0,0.0,bannerView.frame.size.width, bannerView.frame.size.height);
    [UIView commitAnimations];
    NSLog(@"Banner is moved to the screen");
    */
    
//}

/*//When user pressed the banner then this method will be fired
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"banner is full screen");
    return YES;
}

//After banner is closed (you should restore any services paused by your application/banner)
-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"iAd banner is closed");
}

//Could not load banner, we need to move that banner to off screen (apple required)
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"banner got error");
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    //[self moveBannerOffScreen];
}

@end
*/