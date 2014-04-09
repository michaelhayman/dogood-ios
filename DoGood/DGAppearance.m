#import "DGAppearance.h"
#import <TTTAttributedLabel.h>

@implementation DGAppearance

+ (void)setupAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [[[UIApplication sharedApplication] delegate] window].backgroundColor = MUD;
}

- (void)listFonts {
    for (NSString* family in [UIFont familyNames]) {
        DebugLog(@"%@", family);
        for (NSString* name in [UIFont fontNamesForFamilyName: family]) {
            DebugLog(@"  %@", name);
        }
    }
}

+ (UIColor *)makeContrastingColorFromColor:(UIColor *)newColor {
    UIColor *color;
    if (newColor == nil) {
        return MUD;
    }

    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);

    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5) {
        color = [UIColor whiteColor];
    }
    else {
        color = MUD;
    }
    return color;
}

+ (NSDictionary *)linkAttributes {
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:LINK_COLOUR, [NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    return linkAttributes;
}

+ (NSDictionary *)activeLinkAttributes {
    return [self linkAttributes];
}

+ (CGFloat)calculateHeightForText:(NSAttributedString *)string andWidth:(CGFloat)width {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGSize size = rect.size;
    CGFloat height = ceilf(size.height);
    // CGFloat width  = ceilf(size.width);

    return height;
}

+ (CGFloat)calculateHeightForString:(NSString *)string WithFont:(UIFont *)font andWidth:(CGFloat)width {
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];

    CGRect rect = [attrString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGSize size = rect.size;
    CGFloat height = ceilf(size.height);

    return height;
}

+ (UIView *)createLoadingViewCenteredOn:(UIView *)view {
    UIView *loadingView = [[UIView alloc] initWithFrame:view.frame];
    loadingView.backgroundColor = [UIColor whiteColor];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = view.center;
    spinner.frame = CGRectMake(spinner.frame.origin.x, spinner.frame.origin.y  / 2, spinner.frame.size.width, spinner.frame.size.height);
    [loadingView addSubview:spinner];
    [spinner startAnimating];
    return loadingView;
}

+ (UIColor *)getColorFromHexValue:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)pluralForCount:(NSNumber *)count {
    NSString *plural;
    if ([count isEqualToNumber:[NSNumber numberWithInt:1]]) {
        plural = @"";
    } else {
        plural = @"s";
    }
    return plural;
}

+ (void)tabOn:(UIButton *)button {
    [button setSelected:YES];
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.textColor = MUD;
}

+ (void)tabOff:(UIButton *)button {
    [button setSelected:NO];
    button.backgroundColor = BARK;
    button.titleLabel.textColor = [UIColor whiteColor];
}

@end
