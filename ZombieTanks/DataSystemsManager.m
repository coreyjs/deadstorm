//
//  DataSystemsManager.m
//  ZombieTanks
//
//  Created by Corey Schaf on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataSystemsManager.h"

@implementation DataSystemsManager

@synthesize viewController;

static DataSystemsManager *s_sharedContext = nil;

+(DataSystemsManager *) getDataSystemsManager{
    
    if(!s_sharedContext){
        s_sharedContext = [[self alloc] init];
    }
    
    return s_sharedContext;
}

-(id) init{
    
    if (self = [super init]){
        
        viewController = [[UIViewController alloc] init];
        
        
    }
    
    return self; 
}


-(void) tweetMessage{
    
    
    // check if twitter is setup
    if([TWTweetComposeViewController canSendTweet]){
        
        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        
        // set initial text - TODO: EXTRACT???
        [tweetViewController setInitialText:@"#Deadstorm"];
        
        // setup completion handler
        tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            if(result == TWTweetComposeViewControllerResultDone) {
                // the user finished composing a tweet
            } else if(result == TWTweetComposeViewControllerResultCancelled) {
                // the user cancelled composing a tweet
            }
            [viewController dismissViewControllerAnimated:YES completion:nil];
        };
        
        [[[CCDirector sharedDirector] view] addSubview:viewController.view];
        [viewController presentViewController:tweetViewController animated:YES completion:nil];
    }else{
        // twitter account not configured
        CCLOG(@"NO TWITTER ACCOUNT CONFIGURED");
    }
}

// Overloaded method for custom message sending
-(void) tweetMessage:(NSString*)message{
    
    
    // check if twitter is setup
    if([TWTweetComposeViewController canSendTweet]){
        
        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        
        //[tweetViewController setEditing:NO]; // why is this twice?
        
        [tweetViewController setInitialText:message];
        // XXXXX does this fix the ability to not be able to edit tweets?
        [tweetViewController setEditing:NO animated:NO];
        [viewController setEditing:NO];
       
        // setup completion handler
        tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            if(result == TWTweetComposeViewControllerResultDone) {
                // the user finished composing a tweet
            } else if(result == TWTweetComposeViewControllerResultCancelled) {
                // the user cancelled composing a tweet
            }
            [viewController dismissViewControllerAnimated:YES completion:nil];
        };
        
        [[[CCDirector sharedDirector] view] addSubview:viewController.view];
        
        [viewController presentViewController:tweetViewController animated:YES completion:nil];
    }else{
        // twitter account not configured
        CCLOG(@"NO TWITTER ACCOUNT CONFIGURED");
    }
}

@end
