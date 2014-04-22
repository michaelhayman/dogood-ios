#import "UIViewController+DGViewController.h"

@implementation UIViewController (DGViewController)

- (void)setupMenuTitle:(NSString *)title withColor:(UIColor *)color {
    self.title = title;
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    view.text = self.navigationItem.title;
    view.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    view.textColor = color;
    view.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = [UIColor clearColor];
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    [view addGestureRecognizer:tap];
    [self setupMenuView:view];
}

- (void)setupMenuTitle:(NSString *)title {
    [self setupMenuTitle:title withColor:MUD];
}

- (void)setupMenuImage:(UIImage *)image {
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    view.image = image;
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tour)];
    [view addGestureRecognizer:tap];
    [self setupMenuView:view];
}

- (void)setupMenuView:(UIView *)view {
    view.userInteractionEnabled = YES;
    view.tag = 669;
    [view sizeToFit];
    self.navigationItem.titleView = view;
    self.navigationController.navigationBar.barTintColor = VIVID;
}

- (void)tour {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGTourWasRequested object:nil];
}

- (void)updateTitleColor:(UIColor *)newColor {
    UILabel *view = (UILabel *)[self.navigationItem.titleView viewWithTag:669];
    view.textColor = [DGAppearance makeContrastingColorFromColor:newColor];
}

- (void)toggleMenu {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
