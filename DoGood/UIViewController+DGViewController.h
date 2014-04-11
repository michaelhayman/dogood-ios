@interface UIViewController (DGViewController)

- (void)setupMenuTitle:(NSString *)title;
- (void)setupMenuTitle:(NSString *)title withColor:(UIColor *)color;
- (void)setupMenuImage:(UIImage *)image;
- (void)updateTitleColor:(UIColor *)newColor;

@end
