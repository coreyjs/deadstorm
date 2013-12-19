//
//  EnemyCache.h
//  ZombieTanks
//
//  Created by Corey Schaf on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "EnemyEntity.h"


@interface EnemyCache : CCNode{
    
    CCSpriteBatchNode *_enemyCacheSpriteBatchNode;
    CCArray *_enemies;
    int _updateCount;
    
}

@end
