#import "DGTracker.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation DGTracker

static DGTracker* _sharedTracker = nil;

+ (DGTracker *)sharedTracker {
    if (_sharedTracker == nil) {
        _sharedTracker = [[DGTracker alloc] init];
        [GAI sharedInstance].trackUncaughtExceptions = NO;

        [GAI sharedInstance].dispatchInterval = 20;

        if (DEVELOPMENT) {
            [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
        } else {
            [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
        }
        [[GAI sharedInstance] trackerWithTrackingId:@"UA-35187011-2" ];
    }
    return _sharedTracker;
}

- (void)startTracking {

}

- (void)trackUserSignIn:(DGUser *)user {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:@"&uid" value:[NSString stringWithFormat:@"%@", user.userID]];

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX" action:@"User Sign In" label:nil value:nil] build]];
}

- (void)trackScreen:(NSString *)screen {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:kGAIScreenName value:screen];

    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:nil] build]];
}

@end
