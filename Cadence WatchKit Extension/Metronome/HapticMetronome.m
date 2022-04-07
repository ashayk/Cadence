//
//  HapticMetronome.m
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 1/5/21.
//

#import "HapticMetronome.h"
#import <WatchKit/WatchKit.h>
#import "AudioPlayer.h"
#import "AudioEngine.h"
#import "FifoBuffer.h"

@interface HapticMetronome() {
    
}
@property(nonatomic, strong) NSTimer* timer;
@property(nonatomic, strong) AudioPlayer* player;
@property(nonatomic, strong) AVAudioSourceNode* source;
@property int hapticCounter;
@property(nonatomic, strong) NSMutableData* snapData;
@property(nonatomic, strong) FifoBuffer* fifo;
@end

@implementation HapticMetronome

-(id)init {
    self = [super init];
    if(self) {
        NSURL *sample = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Snap" ofType:@"wav"]];
        NSError* error;
        AVAudioFile* audioAsset = [[AVAudioFile alloc] initForReading:sample error:&error];
        self.player = [[AudioPlayer alloc] initWithAsset:audioAsset];
        self.fifo = [[FifoBuffer alloc] init];
        [self setupSourceNode];
    }
    return self;
}

-(void)setupSourceNode {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SnapRaw" ofType:@"raw"];
    self.snapData = [NSMutableData dataWithContentsOfFile:path];
    
    AVAudioFormat* inputFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16 sampleRate:44100. channels:1 interleaved:YES];
    
    __weak __typeof(self) wself = self;
    self.source = [[AVAudioSourceNode alloc] initWithFormat:inputFormat renderBlock:^OSStatus(BOOL * _Nonnull isSilence, const AudioTimeStamp * _Nonnull timestamp, AVAudioFrameCount frameCount, AudioBufferList * _Nonnull ioData) {
        
        *isSilence = NO;
        for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
            memset(ioData->mBuffers[iBuffer].mData, 0, ioData->mBuffers[iBuffer].mDataByteSize);
        }
        
        for (int i = 0 ; i < ioData->mNumberBuffers; i++){
            //get the buffer to be filled
            AudioBuffer abuffer = ioData->mBuffers[i];
            int size = abuffer.mDataByteSize;
            while([wself.fifo length] < size) {
                [wself fillAudio];
            }
            
            [wself.fifo get:(unsigned char*)abuffer.mData len:size];
        }
        
        return noErr;
    }];
    
    [audioEngine.audioEng attachNode:self.source];
    [audioEngine.audioEng connect:self.source to:audioEngine.audioEng.outputNode format:inputFormat];
}

-(void)fillAudio {
    
    [self.fifo put:(unsigned char*)[self.snapData bytes] len:(int)[self.snapData length]];
    self.hapticCounter++;
    if(self.hapticCounter % 4 == 0 && [[self class] areHeadphonesPluggedIn] == NO) {
        [self playHaptic];
    }
    
    // add the silence
    static double dur = .1;
    double silenceTime = [self computeSilenceTime:dur];
    int numBytes = [self secondsToBytes:silenceTime];
    
    if(numBytes > 0) {
        unsigned char* sBytes = malloc(numBytes);
        memset(sBytes, 0, numBytes);
        [self.fifo put:sBytes len:numBytes];
        free(sBytes);
    }
}

-(double)computeSilenceTime:(double)dur {
    double send = (60.0 / (double) self.bpm) - dur;
    if(send < 0) {
        send = 0;
    }
    return send;
}

-(int)secondsToBytes:(double)sec {
    int send = (int)(sec * 44100. * 2.);
    if((send % 2) != 0) {
        send--;
    }
    return send;
}

-(void)start {
    if(! _running) {
        [audioEngine startEngine];
        _running = YES;
    }
}

-(void)stop {
    if(_running) {
        [audioEngine stopEngine];
        _running = NO;
    }
}

-(void)schedulePlay {
    double multiplier = self.halveIt ? 2. : 1;
    double time = multiplier * 60./(double)_bpm;
    _running = YES;
    __weak __typeof(self) wself = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time repeats:NO block:^(NSTimer * _Nonnull timer) {
        if(wself.running) {
            [wself.player play];
            wself.hapticCounter++;
            if(wself.hapticCounter % 4 == 0) {
                [wself playHaptic];
            }
            [wself schedulePlay];
        }
    }];
}

-(void)playHaptic {
    [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeStart];
}

-(void)dealloc {
    _running = NO;
    [self.timer invalidate];
}

+ (BOOL)areHeadphonesPluggedIn {
        
    NSArray *availableOutputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    BOOL send = YES;
    for (AVAudioSessionPortDescription *portDescription in availableOutputs) {
        if ([portDescription.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            send = NO;
        }
    }

    return send;
}

@end
