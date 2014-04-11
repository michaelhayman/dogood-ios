#import "UIViewController+DGViewController.h"
#import "DGAppearance.h"

@implementation UIViewController (DGViewController)

- (void)setupMenuTitle:(NSString *)title {
    self.title = title;
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    view.text = self.navigationItem.title;
    view.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    view.textColor = MUD;
    view.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = YES;
    [self setupMenuView:view];
}

- (void)setupMenuImage:(UIImage *)image {
    UIImageView *logo = [[UIImageView alloc] initWithImage:image];
    [self setupMenuView:logo];
}

- (void)setupMenuView:(UIView *)view {
    view.userInteractionEnabled = YES;
    view.tag = 669;
    [view sizeToFit];
    self.navigationItem.titleView = view;
    self.navigationController.navigationBar.barTintColor = VIVID;
}

- (void)updateTitleColor:(UIColor *)newColor {
    UILabel *view = (UILabel *)[self.navigationItem.titleView viewWithTag:669];
    view.textColor = [DGAppearance makeContrastingColorFromColor:newColor];
}

- (void)toggleMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidToggleMenu object:nil];
}

@end
