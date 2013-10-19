@interface DGAppearance : NSObject

+ (void)setupAppearance;
+ (NSDictionary *)linkAttributes;
+ (CGFloat)calculateHeightForText:(NSAttributedString *)string andWidth:(CGFloat)width;

@end
