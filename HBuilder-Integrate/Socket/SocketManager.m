//
//  SocketManager.m
//  TCPSocketServer-Demo
//  Copyright © 2016年 Steven. All rights reserved.
//

#import "SocketManager.h"
#import "GCDAsyncSocket.h"

@implementation SocketManager
+ (SocketManager *)sharedSocketManager
{
    static SocketManager *socket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [[SocketManager alloc] init];
    });
    return socket;
}
@end
