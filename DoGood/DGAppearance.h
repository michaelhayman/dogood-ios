@interface DGAppearance : NSObject

+ (void)setupAppearance;
+ (NSDictionary *)linkAttributes;
+ (NSDictionary *)activeLinkAttributes;
+ (CGFloat)calculateHeightForText:(NSAttributedString *)string andWidth:(CGFloat)width;
+ (UIView *)createLoadingViewCenteredOn:(UIView *)view;
+ (UIColor *)getColorFromHexValue:(NSString *)hex;
+ (NSString *)pluralForCount:(NSNumber *)count;

@end
