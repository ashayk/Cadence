//
//  AudioEngine.m
//
//  Created by Alex Shaykevich on 23/4/18.
//  Copyright © 2018 Alex Shaykevich. All rights reserved.
//

#import "AudioEngine.h"

@interface AudioEngine() {
    
}
@property(nonatomic, strong) AVAudioPlayerNode* audioPlayer;

@end
@implementation AudioEngine

+ (AudioEngine*)singleton
{
    // 1
    static AudioEngine *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[AudioEngine alloc] init];
    });
    return _sharedInstance;
}

-(id)init {
    self = [super init];
    if(self) {
        [self setupAudioEngine];
    }
    return self;
}

-(void)setupAudioEngine {
    self.audioPlayer = [[AVAudioPlayerNode alloc] init];
    self.audioEng = [[AVAudioEngine alloc] init];
    [_audioEng attachNode:_audioPlayer];
    
    NSURL *sample = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Snap" ofType:@"wav"]];
    NSError* error;
    AVAudioFile* audioAsset = [[AVAudioFile alloc] initForReading:sample error:&error];
    AVAudioFormat* format = [audioAsset processingFormat];
    
    [_audioEng connect:_audioPlayer to:_audioEng.mainMixerNode format:format];
}

-(void)play:(AVAudioFile*)file completion:(AVAudioNodeCompletionHandler)completion
{
    if(_audioEng.running) {
        [_audioPlayer scheduleFile:file atTime:nil completionHandler:completion];
        [_audioPlayer play];
    }
}

-(void)playLoop:(AVAudioPCMBuffer*)buffer {
    [_audioPlayer scheduleBuffer:buffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
    [_audioPlayer play];
}

-(void)stop {
    [_audioPlayer stop];
}

-(void)startEngine {
    if(! _audioEng.isRunning) {
        [_audioEng startAndReturnError:nil];
    }
}

-(void)stopEngine {
    if(_audioEng.isRunning) {
        [_audioEng pause];
    }
}



@end
