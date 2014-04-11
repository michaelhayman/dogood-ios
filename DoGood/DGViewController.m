#import "UINavigationBar+Addition.h"

@interface DGViewController ()

@end

@implementation DGViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = [DGAppearance barButtonItemWithNoText];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar hideBottomHairline];
}

@end
