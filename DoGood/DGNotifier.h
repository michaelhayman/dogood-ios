//
//  MBONotifier.h
//  MomentBooks
//
//  Created by Michael on 2014-12-08.
//  Copyright (c) 2014 Springbox. All rights reserved.
//

@class RavenClient;

@interface DGNotifier : NSObject

+ (DGNotifier *)sharedManager;
+ (RavenClient *)client;
- (void)start;
- (void)sendFailure:(NSString *)failure;

@end
