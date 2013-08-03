#import "NavigationViewController.h"
#import "DGAppDelegate.h"
// #import "Foursquare-API-v2/Foursquare2.h"
#import "DGWelcomeViewController.h"
#import "DGGoodListViewController.h"
#import "DGGood.h"
#import "DGCategory.h"
#import "DGComment.h"
#import "DGLocation.h"
#import <NUI/NUIAppearance.h>

@implementation DGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NUIAppearance init];
    /*
     [self listFonts];
    */
    int imageSize = 20; //REPLACE WITH YOUR IMAGE WIDTH

    UIImage *barBackBtnImg = [[UIImage imageNamed:@"BackButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, imageSize, 0, 0)];
    UIImage *barBackBtnImgTap = [[UIImage imageNamed:@"BackButtonTap"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, imageSize, 0, 0)];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImgTap
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
    /*  this should work but doesn't
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.backgroundColor = [UIColor clearColor];
    [bt setFrame:CGRectMake(0, 0, 60, 60)];

    UIImage *barBackBtnImg = [[UIImage imageNamed:@"BackButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 24, 0, 0)];
    UIImage *barBackBtnImgTap = [[UIImage imageNamed:@"BackButtonTap"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 24, 0, 0)];
    [bt setImage:barBackBtnImg forState:UIControlStateNormal];
    [bt setImage:barBackBtnImgTap forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:bt];
    DebugLog(@"hey %@", leftButton);
    //[[UIBarButtonItem appearance] setBackBarButtonItem:leftButton];
    //[[UIBarButtonItem appearance] setBack]
     */

    UIImage *image = [UIImage imageNamed:@"NavBar.png"];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

    // [[UILabel appearance] setFont
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
    DebugLog(@"test");
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    [self setupParse];
    [self setupParseTracking:launchOptions];
    [self setupParseUser];
    [self setupFoursquare];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)listFonts {
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);

        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}

- (void)setupFoursquare {
    /*
    [Foursquare2 setupFoursquareWithKey:@"EWRCKLKQ4O2LVVYK1ADLNXHTBS3MTYY1JMNPNJCM3SZ1ATII"
                                 secret:@"VZGH0QRJFF4AOU3WTXON0XZZQJ3YKMYLEUQ3ZRCQ0HZBDVTP"
                            callbackURL:@"app://dogood"];
    */
}

- (void)setupParseUser {

    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        UIStoryboard *storyboard;
        storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
        DGGoodListViewController *wallViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];

        UINavigationController *navController = [[NavigationViewController alloc] initWithRootViewController:wallViewController];
        navController.navigationBarHidden = NO;
        self.window.rootViewController = [[NavigationViewController alloc] initWithRootViewController:wallViewController];
    }
    else {
        UIStoryboard *storyboard;
        storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
        DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];

        NavigationViewController *navController = [[NavigationViewController alloc] initWithRootViewController:welcomeViewController];
        navController.navigationBarHidden = YES;
        self.window.rootViewController = navController;
    }
}

- (void)setupParse {
    [DGCategory registerSubclass];
    [DGLocation registerSubclass];
    [DGGood registerSubclass];
    [DGComment registerSubclass];

    [Parse setApplicationId:@"yX6oa70RuofYiE2M63ip2Cn3kg5kzdaoYSyhqrc9"
                 clientKey:@"KzCNmFesB2QbAVGMdnXlPd8tNxliGDFpor7rhC4Y"];

    // 151726295032833
    // 7897c383c114b23833ec5f74b2646ed3
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"99pekoExHF1xHxkL962w"
                               consumerSecret:@"kCIfoX8CdZjJh19NxGSHf4yt51szN2UpHBm9QZiK4"];

    /*
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            NSLog(@"The user is no longer associated with their Facebook account.");
        } else {
            NSLog(@"%@", [error description]);
        }
    }];
    */

    DebugLog(@"Session %@", [PFFacebookUtils session]);

    /*
    [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            NSLog(@"The user is no longer associated with their Twitter account.");
        } else {
            NSLog(@"%@", [error description]);
        }
    }];
    */

    PFQuery *query = [DGCategory query];
    // [query whereKey:@"rupees" lessThanOrEqualTo:PFUser.currentUser.rupees];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.categories = objects;
        }
    }];
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

#pragma mark - Facebook
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

@end
