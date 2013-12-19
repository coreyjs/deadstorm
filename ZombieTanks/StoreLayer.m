//
//  StoreLayer.m
//  ZombieTanks
//
//  Created by Corey Schaf on 11/9/12.
//
//

#import "StoreLayer.h"
#import "SceneManager.h"
//#import "IAdHelper.h"
#import "InAppDeadstormHelper.h"

@implementation StoreLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
	StoreLayer *layer = [[StoreLayer alloc] init];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
   	
	// return the scene
	return scene;
}

-(id) init{
    
    if( self = [super init] ){
        
        CCSprite* background;//
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        if(winSize.width == 568){
            background = [CCSprite spriteWithFile:@"grating-bkgd2-5-hd.png"];
        }else{
            background = [CCSprite spriteWithFile:@"grating-bkgd2.png"];
        }
        
        background.anchorPoint = CGPointMake(0, 0);
        [self addChild: background z:0];

        // the back button
        CCMenuItemImage *backButton = [CCMenuItemImage itemWithNormalImage:@"back_button2.png" selectedImage:@"back_button2_over.png" disabledImage:@"back_button2.png" target:self selector:@selector(back:)];
        
        CCMenu *_backmenu = [CCMenu menuWithItems:backButton, nil];
        if(winSize.width == 568){ //iPhone 5 resolution
            [_backmenu setPosition:ccp(winSize.width * 0.84f, winSize.height -75)];
        }
        else{ // iPhone 4s and whatever
            [_backmenu setPosition:ccp(winSize.width * 0.90f, winSize.height -75)];
        }
        //NSLog(@"SCREEN WIDTH: %f", winSize.width);
        [self addChild:_backmenu z:8];
        
        
        CCSprite *m_bkgd = [CCSprite spriteWithFile:@"StoreScreen.png"];
        [m_bkgd setPosition:CGPointMake(winSize.width * 0.5f, winSize.height*0.5)];
        
        [self addChild:m_bkgd z:1];
        
        
        SKProduct *product = [[InAppDeadstormHelper sharedHelper].products objectAtIndex:0];
//        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:product.price];
//        
        NSLog(@"%@", product.localizedTitle);
        NSLog(@"%@", formattedString);
       // CCMenuItemImage *item = [CCMenuItemFont itemWithString:formattedString target:self selector: @selector(buyButtonTapped:)];
//        //CCmenuItemFont *item = [CCMenuItemFont it]
//        item.tag = 0;
        
        // OLD SHIT
        //CCLabelBMFont *price = [CCLabelBMFont labelWithString:formattedString fntFile:@"planecrash_55.fnt"];
        //price.position = ccp( winSize.width/2 , (winSize.height/2)  );
        //[self addChild:price z:10];
        
        CCMenuItemImage *item = [CCMenuItemImage itemWithNormalImage:@"buyAds-button.png" selectedImage:@"buyAds-button-over.png" target:self selector:@selector(buyButtonTapped:)];
        item.tag = 0;
        //item.position = ccp(winSize.height * 0.5f, winSize.width * 0.5f);
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu addChild:item];
        menu.position =  ccp((winSize.width/2) - 10 , (winSize.height/2) - 75 );
//        
        [self addChild:menu z:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
        
        /*
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
        */
    }
    
    return self;
}


- (void)buyButtonTapped:(id)sender {
    
	NSLog(@"Buy Button Clicked");
	CCMenuItemFont *button = (CCMenuItemFont *) sender;
	
    SKProduct *product = [[InAppDeadstormHelper sharedHelper].products objectAtIndex:button.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[InAppDeadstormHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
    
    //self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSLog(@"Buying removal of ads...");
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*5];
    
}

- (void)timeout:(id)arg {
    
    NSLog(@"Timeout!");
    NSLog(@"Please try again later.");
    //_hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	//_hud.mode = MBProgressHUDModeCustomView;
    //[self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

-(void) productsLodaded:(NSNotification*)notification{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    int product_length = 1;
    
    SKProduct *product = [[InAppDeadstormHelper sharedHelper].products objectAtIndex:0];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    NSLog(@"%@", product.localizedTitle);
    NSLog(@"%@", formattedString);

    // create and initialize a Label
    //CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",product.localizedTitle] fontName:@"Marker Felt" fontSize:36];
    
    // ask director the the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // position the label on the center of the screen
    //label.position =  ccp( size.width/2 , size.height/2 - (1 * 100) );
    
    // add the label as a child to this Layer
    //[self addChild: label z:10];

    if ([[InAppDeadstormHelper sharedHelper].purchasedProducts containsObject:product.productIdentifier]) {
        
    } else {
        CCMenuItemFont *item = [CCMenuItemFont itemFromString:formattedString target:self selector: @selector(buyButtonTapped:)];
        item.tag = 0;
        item.position = ccp(0, (0 * -100) - 30);
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu addChild:item];
        menu.position =  ccp( size.width/2 , size.height/2);
        
        [self addChild:menu z:10];
    }
    
}

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    NSString *productIdentifier = (NSString *) notification.object;
    NSLog(@"Purchased: %@", productIdentifier);
    
    //[self.tableView reloadData];
    
}

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                         message:transaction.error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    
}


-(void) back:(id) sender{
    
    // [[IAdHelper sharedInstance] moveBannerOffScreen];
    
    [SceneManager gotoMenu];
}

@end
