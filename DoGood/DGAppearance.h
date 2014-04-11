@interface DGAppearance : NSObject

+ (void)setupAppearance;
+ (NSDictionary *)linkAttributes;
+ (NSDictionary *)activeLinkAttributes;
+ (CGFloat)calculateHeightForText:(NSAttributedString *)string andWidth:(CGFloat)width;
+ (CGFloat)calculateHeightForString:(NSString *)string WithFont:(UIFont *)font andWidth:(CGFloat)width;
+ (UIView *)createLoadingViewCenteredOn:(UIView *)view;
+ (UIColor *)getColorFromHexValue:(NSString *)hex;
+ (NSString *)pluralForCount:(NSNumber *)count;
+ (UIColor *)makeContrastingColorFromColor:(UIColor *)newColor;
+ (void)tabButton:(UIButton *)button on:(BOOL)on  withBackgroundColor:(UIColor *)color andTextColor:(UIColor *)textColor;

+ (void)styleActionButton:(UIButton *)button;
+ (void)styleSelectionButton:(UIButton *)button;
+ (UIBarButtonItem *)postBarButtonItemFor:(UIViewController *)controller;
+ (UIBarButtonItem *)barButtonItemWithNoText;

@end
