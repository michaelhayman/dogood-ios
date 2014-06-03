#import "UINavigationBar+Addition.h"

@interface DGViewController ()

@end

@implementation DGViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetToDefaultNavColor];
    self.navigationItem.backBarButtonItem = [DGAppearance barButtonItemWithNoText];
    [UINavigationBar appearance].backIndicatorImage = [UIImage imageNamed:@"BackButton"];
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = [UIImage imageNamed:@"BackButton"];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar hideBottomHairline];
}

@end
