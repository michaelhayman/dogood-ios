#import "DGAppDelegate.h"
// views
#import "NavigationViewController.h"
#import "DGGoodListViewController.h"
// global set up
#import "RestKit.h"
#import "DGAppearance.h"
#import "ThirdParties.h"

@implementation DGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DGAppearance setupAppearance];
    [DGUser setUpUserAuthentication];
    [RestKit setupRestKit];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setupViewsForUser];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupViewsForUser {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];

    self.window.rootViewController = [[NavigationViewController alloc] initWithRootViewController:goodListController];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [ThirdParties facebookHandleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"dogood"]) {
        if ([[url host] hasPrefix:@"users"]) {
            NSArray *urlComponents = [url pathComponents];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * userID = [f numberFromString:urlComponents[1]];
            DebugLog(@"open profile page for %@", userID);
            [DGUser openProfilePage:userID inController:(UINavigationController *)self.window.rootViewController];
        }
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [ThirdParties facebookHandleOpenURL:url];
}

@end
