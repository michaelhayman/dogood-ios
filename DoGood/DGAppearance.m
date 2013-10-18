#import "DGAppearance.h"
#import <TTTAttributedLabel.h>

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

+ (NSDictionary *)linkAttributes {
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:LINK_COLOUR, [NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    return linkAttributes;
}

@end
