//
//  AudioManager.h
//  ZombieTanks
//
//  Created by Corey Schaf on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>



@interface AudioManager : NSObject {
    
    ALCcontext* mContext;
	ALCdevice* mDevice;
	NSMutableDictionary *soundDictionary;
	NSMutableArray *bufferStorageArray;
}

-(id) init;
-(void) loadFile:(NSString *)soundName doesLoop:(BOOL)loops;
-(void) playSound:(NSString*)soundKey;
-(void) pauseAllSounds;
-(void) resumeAllSounds;
-(void) pauseSound:(NSString*)soundKey;
-(void) stopAllSounds;
-(void) loadFile:(NSString *)soundName withKey:(NSString*)key doesLoop:(BOOL)loops;

@property(nonatomic, copy) NSMutableDictionary	*soundDictionary;
@property(nonatomic, copy) NSMutableArray		*bufferStorageArray;

@end
