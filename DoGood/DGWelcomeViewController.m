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
    self.title = @"Welcome";
    self.navigationItem.title = @"Welcome";
    // self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    if ([DGUser currentUser]) {
        self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [[DGUser currentUser] username]];
    } else {
        // self.welcomeLabel.text = NSLocalizedString(@"%@\nNot logged in", nil);
    }
}

/*
- (IBAction)signIn:(id)sender {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGSignInViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
    DebugLog(@"controller %@", controller);
    [self.navigationController pushViewController:controller animated:YES];
}
*/

@end

