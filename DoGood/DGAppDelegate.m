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
    [ThirdParties setupFoursquare];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setupViewsForUser];
    [self.window makeKeyAndVisible];
    return YES;
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

- (void)setupViewsForUser {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];

    self.window.rootViewController = [[NavigationViewController alloc] initWithRootViewController:goodListController];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Things that don't really belong in here

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

@end
