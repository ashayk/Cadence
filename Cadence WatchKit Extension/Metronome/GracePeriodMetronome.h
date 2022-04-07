//
//  GracePeriodMetronome.h
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 2/5/21.
//

#import "HapticMetronome.h"

NS_ASSUME_NONNULL_BEGIN

@interface GracePeriodMetronome : HapticMetronome

@property double gracePeriod;
@property(nonatomic) BOOL grace;

-(id)initWithGracePeriod:(double)gp;


@end

NS_ASSUME_NONNULL_END
