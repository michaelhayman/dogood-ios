#import "DGAppDelegate.h"
// views
#import "NavigationViewController.h"
#import "DGGoodListViewController.h"
// #import "DGWelcomeViewController.h"
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    self.window.rootViewController = [[NavigationViewController alloc] initWithRootViewController:goodListController];

       /*
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    // UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
                  */
    // self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:goodListController];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    DebugLog(@"handle open url");
    if ([[url scheme] isEqualToString:@"dogood"]) {
        DebugLog(@"handle dogood");
        if ([[url host] hasPrefix:@"users"]) {
            NSArray *urlComponents = [url pathComponents];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * userID = [f numberFromString:urlComponents[1]];
            DebugLog(@"open profile page for %@", userID);
            [DGUser openProfilePage:userID inController:(UINavigationController *)self.window.rootViewController];
        }
        if ([[url host] hasPrefix:@"goods"]) {
            NSArray *urlComponents = [url pathComponents];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * goodID = [f numberFromString:urlComponents[1]];
            DebugLog(@"open good page for %@", goodID);

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
            DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
            controller.goodID = goodID;
            [(UINavigationController *)self.window.rootViewController pushViewController:controller animated:YES];
        }
        return YES;
    } else {
        return [ThirdParties facebookHandleOpenURL:url];
    }
}

@end
