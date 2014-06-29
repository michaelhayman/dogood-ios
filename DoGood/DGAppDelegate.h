#import <HockeySDK/HockeySDK.h>
@interface DGAppDelegate : UIResponder <UIApplicationDelegate, BITHockeyManagerDelegate> {
    BOOL notified;
}

@property (strong, nonatomic) UIWindow *window;

@end
