//
//  FifoBuffer.m
//
//  Created by Alex Shaykevich on 18/12/10.
//

#import "FifoBuffer.h"

@interface FifoBuffer() {
    
}
@property(nonatomic, strong) NSMutableData* data;
@end

@implementation FifoBuffer

-(id)init {
	self = [super init];
	if(self != nil) {
		self.data = [[NSMutableData alloc] initWithCapacity:8192];
		myQueue = dispatch_queue_create("com.custommedia.fifobuffer", 0);
	}
	return self;
}

-(void)put:(unsigned char*)stuff len:(int)len {
	dispatch_sync(myQueue, ^{
		[_data appendBytes:stuff length:len];
	});
}

-(NSInteger)length {
	return [_data length];
}

-(void)clear {
	dispatch_sync(myQueue, ^{
		[_data setLength:0];
	});
}

-(int)get:(unsigned char*)buffer len:(int)len {
	__block int send;
	dispatch_sync(myQueue, ^{
		send = [self _get:buffer len:len];
	});
	return send;
}

-(int)_get:(unsigned char*)buffer len:(int)len {
	
	int send = 0;
	
	if([_data length] == 0) {
		return 0;
	}
	
	int readLen = len;
	if([_data length] < len) {
		readLen = (int)[_data length];
	}
	send = readLen;
	
	[_data getBytes:buffer length:readLen];
	
	// need to remove the difference and reset		
	if(len < [_data length]) {
		int size = (int)[_data length] - len;
		unsigned char* temp = malloc(size);
		NSRange range = NSMakeRange(readLen, size);
		[_data getBytes:temp range:range];
		[_data setLength:0];
		[_data appendBytes:temp length:size];
		free(temp);
	} else if(len >= [_data length]) {
		[_data setLength:0];
	}
	
	return send;
}

@end

