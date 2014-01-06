#import "UIViewController+DGViewController.h"

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
    view.tag = 669;
    [view sizeToFit];
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    [view addGestureRecognizer:tap];
    self.navigationItem.titleView = view;
    self.navigationController.navigationBar.barTintColor = VIVID;
}

- (void)updateTitleColor:(UIColor *)newColor {
    UILabel *view = (UILabel *)[self.navigationItem.titleView viewWithTag:669];
    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);

    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5) {
        view.textColor = [UIColor whiteColor];
        NSLog(@"my color is dark");
    }
    else {
        view.textColor = MUD;
        NSLog(@"my color is light");
    }
}

- (void)toggleMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidToggleMenu object:nil];
}

@end
