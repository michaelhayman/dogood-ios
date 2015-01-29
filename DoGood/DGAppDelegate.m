#import "DGAppDelegate.h"
// views
#import "DGTabBarController.h"
// global set up
#import "RestKit.h"
#import "DGNotification.h"
#import "URLHandler.h"
#import "DGNotifier.h"

@implementation DGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // set window first so that its background colour can be modified by appearance
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [DGAppearance setupAppearance];
    [DGUser setUpUserAuthentication];
    [RestKit setupRestKit];

    [self setupViewsForUser];
    [self.window makeKeyAndVisible];

    [DGNotification reregisterForNotifications];

    [[DGNotifier sharedManager] start];

    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"2aabe4790ed577f27e56c2d215bb9d3d"
                                                           delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];

    return YES;
}

- (void)setupViewsForUser {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    DGTabBarController *controller = [[DGTabBarController alloc] init];
    self.window.rootViewController = controller;
}

#pragma mark - Remote Notification handling
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (!notified) {
        [DGNotification registerToken:deviceToken];
        [DGNotification setNotifiable];
        notified = YES;
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DebugLog(@"failed");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [DGNotification handleNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    DebugLog(@"memory warning... ");
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    DebugLog(@"handle open url");
    URLHandler *handler = [[URLHandler alloc] init];
    [handler openURL:url andReturn:^(BOOL matched) {
        return matched;
    }];
    return YES;
}

@end
