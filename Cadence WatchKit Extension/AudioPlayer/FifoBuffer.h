//
//  FifoBuffer.h
//  VTM_AViPodReader
//
//  Created by Alex Shaykevich on 18/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@interface FifoBuffer : NSObject {
	dispatch_queue_t myQueue;
}

-(NSInteger)length;
-(void)put:(unsigned char*)stuff len:(int)len;
-(int)get:(unsigned char*)buffer len:(int)len;	
-(void)clear;
-(int)_get:(unsigned char*)buffer len:(int)len;

@end

