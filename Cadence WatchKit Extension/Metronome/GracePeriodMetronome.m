//
//  GracePeriodMetronome.m
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 2/5/21.
//

#import "GracePeriodMetronome.h"

@interface GracePeriodMetronome() {
    double lastStopTime;
}
@end

@implementation GracePeriodMetronome

-(id)initWithGracePeriod:(double)gp {
    self = [super init];
    if(self) {
        _gracePeriod = gp;
        lastStopTime = -1;
    }
    return self;
}

-(void)start {
    if(self.running == NO) {
        double now = CFAbsoluteTimeGetCurrent();
        BOOL shouldStart = NO;
        if(lastStopTime > -1) {
            double diff = now - lastStopTime;
            if(diff > _gracePeriod) {
                shouldStart = YES;
            }
        } else {
            shouldStart = YES;
        }
        
        if(shouldStart) {
            [super start];
        }
    }
}

-(void)stop {
    if(self.running) {
        [super stop];
        lastStopTime = CFAbsoluteTimeGetCurrent();
    }
}

-(void)setGrace:(BOOL)grace {
    lastStopTime = CFAbsoluteTimeGetCurrent();
}

-(BOOL)grace {
    return lastStopTime > -1 && (CFAbsoluteTimeGetCurrent() - lastStopTime) <= _gracePeriod;
}

@end

