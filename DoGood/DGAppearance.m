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

    int imageSize = 20;

    UIImage *barBackBtnImg = [[UIImage imageNamed:@"BackButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, imageSize, 0, 0)];
    UIImage *barBackBtnImgTap = [[UIImage imageNamed:@"BackButtonTap"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, imageSize, 0, 0)];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImgTap
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];

    UIImage *image = [UIImage imageNamed:@"NavBar.png"];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

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
