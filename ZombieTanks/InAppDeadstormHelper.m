//
//  InAppDeadstormHelper.m
//  ZombieTanks
//
//  Created by Corey Schaf on 11/9/12.
//
//

#import "InAppDeadstormHelper.h"

@implementation InAppDeadstormHelper

static InAppDeadstormHelper *_sharedHelper;

+(InAppDeadstormHelper *) sharedHelper{
    
    if(_sharedHelper != nil){
        return _sharedHelper;
    }
    _sharedHelper = [[InAppDeadstormHelper alloc] init];
    return _sharedHelper;
}

-(id) init{
    

    
    NSSet *productIdentifiers = [NSSet setWithObjects:@"com.blaqksheep.deadstorm.removeads", nil];
    
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {
        
    }
    return self;
}

@end
