#import "DGAppearance.h"

@implementation DGAppearance

+ (void)setupAppearance {
    // [NUIAppearance init];
    /*
    UISS *uiss = [UISS configureWithDefaultJSONFile];
    uiss.autoReloadEnabled = YES;
    uiss.autoReloadTimeInterval = 1;
    uiss.statusWindowEnabled = YES;
    */

    // int imageSize = 20;

    /*
    UIImage *barBackBtnImg = [[UIImage imageNamed:@"BackButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, imageSize, 0, 0)];
    UIImage *barBackBtnImgTap = [[UIImage imageNamed:@"BackButtonTap"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, imageSize, 0, 0)];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImgTap
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
         */
    /*
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefaultPrompt];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImgTap
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefaultPrompt];
     */
    // uibarmetrics

    // UIImage *image = [UIImage imageNamed:@"NavBar.png"];
    // [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    // [[UINavigationBar appearance] setBackgroundColor:[UIColor redColor]];
    // UIColor *redColor = [UIColor colorWithRed:239.0/255.0 green:80.0/255.0 blue:40.0/255.0 alpha:1.0];
    /*
    UIColor *redColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.1];
    [[UINavigationBar appearance] setBarTintColor:redColor];


    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
     */
    UIColor *greenColor = [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:134.0/255.0 alpha:1.1];

    [[UIBarButtonItem appearance] setTintColor:greenColor];

    UIColor *creamColor = [UIColor colorWithRed:253.0/255.0 green:246.0/255.0 blue:227.0/255.0 alpha:0.1];
    [[UINavigationBar appearance] setBarTintColor:creamColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    // [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    // [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"NavBar.png"]];
}

- (void)listFonts {
    for (NSString* family in [UIFont familyNames]) {
        DebugLog(@"%@", family);
        for (NSString* name in [UIFont fontNamesForFamilyName: family]) {
            DebugLog(@"  %@", name);
        }
    }
}

@end
