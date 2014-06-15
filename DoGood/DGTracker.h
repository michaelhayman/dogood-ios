@interface DGTracker : NSObject

+ (DGTracker *)sharedTracker;
- (void)trackUserSignIn:(DGUser *)user;
- (void)trackScreen:(NSString *)screen;
- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label;

@end
