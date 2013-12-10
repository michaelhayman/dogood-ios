#import "DGWelcomeViewController.h"
#import "DGGoodListViewController.h"
#import "DGSignInViewController.h"
#import "DGSignUpViewController.h"

@interface DGWelcomeViewController ()
@end

@implementation DGWelcomeViewController

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barTintColor = VIVID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

@end

