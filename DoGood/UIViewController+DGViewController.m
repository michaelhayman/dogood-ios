#import "UIViewController+DGViewController.h"

@implementation UIViewController (DGViewController)

- (void)setupMenuTitle:(NSString *)title {
    self.title = title;
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    view.text = self.navigationItem.title;
    view.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    view.textColor = [UIColor blackColor];
    view.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = YES;
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    [view addGestureRecognizer:tap];
    self.navigationItem.titleView = view;
}

- (void)toggleMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidToggleMenu object:nil];
}

@end
