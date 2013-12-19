//
//  AppDelegate.m
//  ZombieTanks
//
//  Created by Corey Schaf on 1/26/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "MenuScene.h"
//#import "RootViewController.h"
#import "GCHelper.h"
#import "Appirater.h"
#import "GameScene.h"
#import "TransitionLayer.h"
//#import "IAdHelper.h"
#import "InAppDeadstormHelper.h"
#import "Reachability.h"

@implementation AppDelegate

@synthesize window = window_;
@synthesize viewController = viewController_;
@synthesize director = director_;
@synthesize navController = navController;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if your Application only supports landscape mode
	//

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[InAppDeadstormHelper sharedHelper]];
    
    // Check for in app purchases from server
   // Reachability *reach = [Reachability reachabilityForInternetConnection];
   // NetworkStatus netStatus = [reach currentReachabilityStatus];
   // if (netStatus == NotReachable) {
    //    NSLog(@"No internet connection!");
   // } else {
        if ([InAppDeadstormHelper sharedHelper].products == nil) {
            
            [[InAppDeadstormHelper sharedHelper] requestProducts];
            //self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            NSLog(@"Loading purchases...");
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
            
        }
  //  }
    
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	//CCDirector *director = [CCDirector sharedDirector];
	director_ = (CCDirectorIOS *)[CCDirector sharedDirector];
    director_.wantsFullScreenLayout = YES;
    
    // GAME CENTER MAB XXXXX
//    [[GCHelper sharedInstance] authenticateLocalUser];
//    
    
   // director_.interfaceOrientation = UIInterfaceOrientationLandscapeLeft;

    
    // Init the View Controller
	//viewController_ = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	//viewController_.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
//	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
//								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
//								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
//						];

	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
    
    
	// attach the openglView to the director
	[director_ setView:glView];
    
    
    [director_ setDelegate:self];
	
    [director_ setProjection:kCCDirectorProjection2D];
    
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Retina Display Not supported <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
		
	[director_ setAnimationInterval:1.0/30];
	//[director setDisplayStats:YES];
	
    
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
     [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
	// PVR Textures have alpha premultiplied
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
    
    navController = [[UINavigationController alloc] initWithRootViewController:director_];
    navController.navigationBarHidden = YES;
    
    //[[IAdHelper sharedInstance] createAdView];
    //[navController.view addSubview:[[IAdHelper sharedInstance] bannerView]];
    //[[IAdHelper sharedInstance] moveBannerOffScreen];
    
    [window_ setRootViewController:navController];
    
    [window_ makeKeyAndVisible];
    [Appirater appLaunched:YES];


    //[director_ runWithScene:[TransitionLayer scene ]];
    //[director_ pushScene:[TransitionLayer scene]];
    
   
    
    return YES;
}

- (void)timeout:(id)arg {
    
    NSLog(@"Timeout!");
    NSLog(@"Please try again later.");
    //_hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	//_hud.mode = MBProgressHUDModeCustomView;
    //[self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director pushScene: [TransitionLayer scene]];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	if( [navController visibleViewController] == director_ )
		[director_ pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	if( [navController visibleViewController] == director_ ){
		[director_ resume];
        [GameScene pause];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

// hit home button or phone call
-(void) applicationDidEnterBackground:(UIApplication*)application {
	
//    [[CCDirector sharedDirector] stopAnimation];
//    [[CCDirector sharedDirector] pause];
//    [GameScene pause];
    
    if( [navController visibleViewController] == director_ )
		[director_ stopAnimation];
}

// back to the foreground while still in memory
-(void) applicationWillEnterForeground:(UIApplication*)application {
//	[[CCDirector sharedDirector] startAnimation];
//    [Appirater appEnteredForeground:YES];
//    //[[CCDirector sharedDirector] resume];
//    [GameScene pause];
    if( [navController visibleViewController] == director_ )
		[director_ startAnimation];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    CC_DIRECTOR_END();
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];

}

// FORCE IT TO RIGHT LANDSCAPE ORIENTATION NO MATTER WHAT!
/*-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
   // interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
        
   // return UIInterfaceOrientationIsLandscape( interfaceOrientation == UIInterfaceOrientationLandscapeLeft );
      //                                       || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
    //how the fuck does this work and why
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}*/

// Override to allow orientations other than the default portrait orientation. XXXXX MAB
// pre iOS6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    
    return UIInterfaceOrientationMaskLandscapeLeft;
    //return UIInterfaceOrientationLandscapeLeft;
}
/*
-(BOOL) shouldAutorotate{
    
    return NO; // XXXXX MAB was YES
    
   // return [[UIDevice currentDevice] orientation] != UIInterfaceOrientationPortrait;
}*/

-(BOOL)shouldAutorotate{
    //if(){
        //return NO;
    //}
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft; // XXXXX MAB
    return UIInterfaceOrientationMaskLandscapeLeft;

    /*if ([viewController firstObject] == YourObject)
    {
        return UIInterfaceOrientationMaskLandscapeLeft;
    }
    return UIInterfaceOrientationMaskPortrait;*/
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}
@end
