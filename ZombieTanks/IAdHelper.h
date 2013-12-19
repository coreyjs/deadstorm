//
//  IAdHelper.h
//  ZombieTanks
//
//  Created by Corey Schaf on 10/9/12.
//
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@interface IAdHelper : NSObject <ADBannerViewDelegate>
{
    
    ADBannerView *bannerView;
    UINavigationController *navController;
    
}

@property (nonatomic, retain) ADBannerView *bannerView;

+(IAdHelper *)sharedInstance;
-(void) createAdView;
-(void) moveBannerOnScreen;
-(void) moveBannerOffScreen;
@end
