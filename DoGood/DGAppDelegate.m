#import "DGAppDelegate.h"
// views
#import "NavigationViewController.h"
#import "DGGoodListViewController.h"
// global set up
#import "RestKit.h"
#import "DGAppearance.h"
#import "URLHandler.h"

@implementation DGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DGAppearance setupAppearance];
    [DGUser setUpUserAuthentication];
    [RestKit setupRestKit];
    // [TestFlight takeOff:@"737117dd-7de4-44f2-8be8-4a3782b60517"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setupViewsForUser];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupViewsForUser {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    self.window.rootViewController = [[NavigationViewController alloc] initWithRootViewController:goodListController];
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
