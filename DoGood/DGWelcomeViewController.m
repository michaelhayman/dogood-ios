#import "DGWelcomeViewController.h"
#import "DGLogInViewController.h"
#import "DGSignUpViewController.h"
#import "DGWelcomeViewController.h"
#import "DGGoodListViewController.h"

@interface DGWelcomeViewController ()
@end

@implementation DGWelcomeViewController

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PFUser currentUser]) {
        self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [[PFUser currentUser] username]];
    } else {
        self.welcomeLabel.text = NSLocalizedString(@"Not logged in", nil);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![PFUser currentUser]) {
        logInViewController = [[DGLogInViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.facebookPermissions = @[@"friends_about_me"];
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;

        signUpViewController = [[DGSignUpViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;
        logInViewController.signUpController = signUpViewController;
    }
}

#pragma mark - PFLogInViewControllerDelegate
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }

    [TSMessage showNotificationInViewController:logInViewController
                                      withTitle:NSLocalizedString(@"Missing Information", nil)
                                    withMessage:NSLocalizedString(@"Make sure you fill out all of the information!", nil)
                                       withType:TSMessageNotificationTypeError];
    return NO;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *wallViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];

    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:wallViewController animated:NO];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - PFSignUpViewControllerDelegate
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }

    if (!informationComplete) {
        [TSMessage showNotificationInViewController:signUpViewController
                                      withTitle:NSLocalizedString(@"Missing Information", nil)
                                    withMessage:NSLocalizedString(@"Make sure you fill out all of the information!", nil)
                                       withType:TSMessageNotificationTypeError];
    }

    return informationComplete;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *wallViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:wallViewController animated:NO];
    [TSMessage showNotificationInViewController:wallViewController
                                  withTitle:NSLocalizedString(@"Sign Up Complete!", nil)
                                withMessage:NSLocalizedString(@"Now do some good!", nil)
                                   withType:TSMessageNotificationTypeSuccess];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

#pragma mark - Custom methods
- (IBAction)signIn:(id)sender {
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (IBAction)register:(id)sender {
    [self presentViewController:signUpViewController animated:YES completion:NULL];
}

- (IBAction)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

