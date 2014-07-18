#import "DGTracker.h"

@implementation DGTracker

static DGTracker* _sharedTracker = nil;

+ (DGTracker *)sharedTracker {
    if (_sharedTracker == nil) {
        _sharedTracker = [[DGTracker alloc] init];
    }
    return _sharedTracker;
}

- (void)startTracking {

}

- (void)trackUserSignIn:(DGUser *)user {
}

- (void)trackScreen:(NSString *)screen {
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label {
}

@end
