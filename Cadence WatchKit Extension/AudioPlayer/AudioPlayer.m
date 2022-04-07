//
//  AudioPlayer.m
//
//  Created by Alex Shaykevich on 23/4/18.
//  Copyright © 2018 Alex Shaykevich. All rights reserved.
//

#import "AudioPlayer.h"
#import "AudioEngine.h"

@interface AudioPlayer() {
    
}
@end
@implementation AudioPlayer

-(id)initWithAsset:(AVAudioFile*)asset {
    self = [super init];
    if(self) {
        self.asset = asset;
        _duration = (AVAudioFrameCount)[_asset length]/44100.;
    }
    return self;
}

-(void)play {
    
    _playing = YES;
    __weak __typeof(self) wself = self;
    [audioEngine play:self.asset completion:^{
        wself.playing = NO;
    }];
}

-(void)stop {
    _playing = NO;
    [audioEngine stop];
}

@end
