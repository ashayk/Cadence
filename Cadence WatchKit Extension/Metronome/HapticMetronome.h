//
//  HapticMetronome.h
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 1/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HapticMetronome : NSObject

@property int bpm;
@property(readonly) BOOL running;
@property BOOL halveIt;

-(void)start;
-(void)stop;
+ (BOOL)areHeadphonesPluggedIn;

@end

NS_ASSUME_NONNULL_END
