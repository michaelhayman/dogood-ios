#import "DGWelcomeViewController.h"
#import "DGLogInViewController.h"
#import "DGSignUpViewController.h"
#import "DGGoodListViewController.h"

@interface DGWelcomeViewController ()
@end

@implementation DGWelcomeViewController

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([DGUser currentUser]) {
        self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [[DGUser currentUser] username]];
    } else {
        // self.welcomeLabel.text = NSLocalizedString(@"%@\nNot logged in", nil);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

@end

