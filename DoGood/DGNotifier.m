#import "DGNotifier.h"
#import "constants.h"
#import <Raven/RavenClient.h>

@implementation DGNotifier

+ (DGNotifier *)sharedManager {
    static DGNotifier *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [DGNotifier alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        [RavenClient clientWithDSN:kRavenDevelopmentDSN];
    }
    return self;
}

+ (RavenClient *)client {
    return [RavenClient sharedClient];
}

- (void)start {
    [[RavenClient sharedClient] setupExceptionHandler];
}

- (void)sendFailure:(NSString *)failure {
    [[RavenClient sharedClient] captureMessage:failure level:kRavenLogLevelDebugInfo method:__FUNCTION__ file:__FILE__ line:__LINE__];
}

@end
