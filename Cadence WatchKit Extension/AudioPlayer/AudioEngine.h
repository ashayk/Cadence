//
//  AudioEngine.h
//
//  Created by Alex Shaykevich on 23/4/18.
//  Copyright © 2018 Alex Shaykevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define audioEngine [AudioEngine singleton]

@interface AudioEngine : NSObject

@property(nonatomic, strong) AVAudioEngine* audioEng;

+ (AudioEngine*)singleton;
-(void)play:(AVAudioFile*)file completion:(AVAudioNodeCompletionHandler)completion;
-(void)playLoop:(AVAudioPCMBuffer*)buffer;
-(void)stop;
-(void)startEngine;
-(void)stopEngine;

@end
