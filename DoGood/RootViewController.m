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

/*
- (void)viewWillDisappear:(BOOL)animated {
    DebugLog(@"dispapeared");
    NavigationViewController *navigationController = (NavigationViewController *)self.navigationController;
    [navigationController.menu close];
}
*/

#pragma mark - Custom button
- (void)addMenuButton:(NSString *)menuButton withTapButton:(NSString *)tapButton {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(toggleMenu)];
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
