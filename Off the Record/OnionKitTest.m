//
//  OnionKitTest.m
//  Off the Record
//
//  Created by David on 1/10/13.
//  Copyright (c) 2013 Chris Ballinger. All rights reserved.
//

#import "OnionKitTest.h"

#define HOST @"check.torproject.org"

@implementation OnionKitTest


-(id)init
{
    if(self = [super init])
    {
        OnionKit * oKit = [OnionKit sharedInstance];
        oKit.delegate = self;
        [oKit start];
        
        
        
    }
    return self;
}

-(void)torDidConnect
{
    NSLog(@"[OnionKitTest] torDidConnect");
    //[self testSocket];
    [self performSelector:@selector(testSocket) withObject:self afterDelay:5];
}

- (void)torConnectingWithMessage:message
{
    NSLog(@"[OnionKitTest] torMessage %@",message);
}

- (void)controlPortDidAuthenticate:(BOOL)didAuthenticate
{
    NSLog(@"[OnionKitTest] controlPortDidAuthenticate");
}

- (void)testSocket
{
    GCDAsyncSocket * socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [socket setProxyHost:@"127.0.0.1" onPort:[[OnionKit sharedInstance] torSocksPort]];
    
    NSError *err = nil;
    [socket connectToHost:HOST onPort:443 error:&err];
    [socket startTLS:nil];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length])];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    if(msg)
    {
        NSLog(@"RX:%@",msg);
    }
    
}
- (void)socket:(GCDAsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"error - disconnecting");
    //you'd probably want to start reconnecting procedure here...
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"disconnected %@",err.description);
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"wrote Data");
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"connected");
    NSString *requestStrFrmt = @"GET / HTTP/1.0\r\nHost: %@\r\n\r\n";
	
	NSString *requestStr = [NSString stringWithFormat:requestStrFrmt, HOST];
	NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
	
	[sock writeData:requestData withTimeout:-1.0 tag:0];
    
    //NSData *responseTerminatorData = [@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];
	//[sock readDataToData:responseTerminatorData withTimeout:-1.0 tag:0];
    [sock readDataToLength:1250 withTimeout:-1.0 tag:0];
}



@end
