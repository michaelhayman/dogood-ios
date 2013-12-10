@interface DGAppearance : NSObject

+ (void)setupAppearance;
+ (NSDictionary *)linkAttributes;
+ (CGFloat)calculateHeightForText:(NSAttributedString *)string andWidth:(CGFloat)width;
+ (UIView *)createLoadingViewCenteredOn:(UIView *)view;
+ (UIColor *)getColorFromHexValue:(NSString *)hex;

@end
