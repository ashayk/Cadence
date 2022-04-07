//
//  AudioPlayer.h
//
//  Created by Alex Shaykevich on 23/4/18.
//  Copyright © 2018 Alex Shaykevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer : NSObject

@property(nonatomic, strong) AVAudioFile* asset;
@property(readonly) double duration;
@property BOOL playing;

-(id)initWithAsset:(AVAudioFile*)asset;
-(void)play;
-(void)stop;

@end
