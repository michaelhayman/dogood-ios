#import "DGAppearance.h"

@implementation DGAppearance

+ (void)setupAppearance {
    [[UIBarButtonItem appearance] setTintColor:COLOUR_GREEN];
    [[UINavigationBar appearance] setTintColor:COLOUR_GREEN];
    [[UIApplication sharedApplication] keyWindow].tintColor = COLOUR_GREEN;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
