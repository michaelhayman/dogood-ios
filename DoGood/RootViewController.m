#import "RootViewController.h"
#import "NavigationViewController.h"
#import "DGUserProfileViewController.h"
#import "DGGoodListViewController.h"

@implementation RootViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NavigationViewController *navigationController = (NavigationViewController *)self.navigationController;
    [navigationController.menu setNeedsLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    /*
    DebugLog(@"dispapeared");
    NavigationViewController *navigationController = (NavigationViewController *)self.navigationController;
    [navigationController.menu close];
    */
}

#pragma mark - Custom button
- (void)addMenuButton:(NSString *)menuButton withTapButton:(NSString *)tapButton {
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.backgroundColor = [UIColor clearColor];
    [bt setFrame:CGRectMake(0, 0, 60, 60)];

    UIImage *barBackBtnImg = [[UIImage imageNamed:menuButton] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 24, 0, 0)];
    UIImage *barBackBtnImgTap = [[UIImage imageNamed:tapButton] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 24, 0, 0)];
    [bt setImage:barBackBtnImg forState:UIControlStateNormal];
    [bt setImage:barBackBtnImgTap forState:UIControlStateHighlighted];
    [bt addTarget:self.navigationController action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.leftBarButtonItem = leftButton;
}

#pragma mark - Rotation
- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
