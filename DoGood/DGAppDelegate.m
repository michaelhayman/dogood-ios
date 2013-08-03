#import "DGAppDelegate.h"
#import "Foursquare-API-v2/Foursquare2.h"
#import "DGWelcomeViewController.h"
#import "DGGoodListViewController.h"

@implementation DGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /* Causing crash
    // Override point for customization after application launch.
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // define roleACL - add ACLs to objects
    PFACL *roleACL = [PFACL ACL];
    PFRole *role = [PFRole roleWithName:@"volunteer" acl:roleACL];
    [role.users addObject:[PFUser currentUser]];
    */
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    [self setupParse];
    [self setupParseTracking:launchOptions];
    [self setupParseUser];
    [self setupFoursquare];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupFoursquare {
    [Foursquare2 setupFoursquareWithKey:@"EWRCKLKQ4O2LVVYK1ADLNXHTBS3MTYY1JMNPNJCM3SZ1ATII"
                                 secret:@"VZGH0QRJFF4AOU3WTXON0XZZQJ3YKMYLEUQ3ZRCQ0HZBDVTP"
                            callbackURL:@"app://dogood"];
}

- (void)setupParseUser {

    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        UIStoryboard *storyboard;
        storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
        DGGoodListViewController *wallViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];

        UINavigationController *navController =
        [[UINavigationController alloc] initWithRootViewController:wallViewController];
        navController.navigationBarHidden = NO;
        [self.window setRootViewController:navController];
    }
    else {
        UIStoryboard *storyboard;
        storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
        DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];

        UINavigationController *navController =
        [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
        navController.navigationBarHidden = YES;
        [self.window setRootViewController:navController];
    }
}

- (void)setupParse {
    [Parse setApplicationId:@"yX6oa70RuofYiE2M63ip2Cn3kg5kzdaoYSyhqrc9"
                 clientKey:@"KzCNmFesB2QbAVGMdnXlPd8tNxliGDFpor7rhC4Y"];
}

- (void)setupParseTracking:(NSDictionary *)launchOptions {
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
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

@end
