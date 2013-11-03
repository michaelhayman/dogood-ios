#import "DGSignInViewController.h"
#import "DGForgotPasswordViewController.h"
#import <MBProgressHUD.h>

@interface DGSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation DGSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.emailField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)signIn:(id)sender {
    [self signInWithEmail:self.emailField.text orUsername:self.emailField.text andPassword:self.passwordField.text showMessage:YES];
}

- (IBAction)forgotPassword:(id)sender {
    DGForgotPasswordViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPassword"];
    controller.signInEmail = self.emailField.text;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)signInWithEmail:(NSString *)email orUsername:(NSString *)username andPassword:(NSString *)password showMessage:(BOOL)message {
    DGUser *user = [DGUser new];
    user.email = email;
    user.password = password;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Signing in...";
    [self.view endEditing:YES];

    [[RKObjectManager sharedManager] postObject:user path:user_session_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [DGUser setCurrentUser:user];
		[DGUser signInWasSuccessful];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }];

        if (message == YES) {
            DebugLog(@"success");
        }
        [TSMessage showNotificationInViewController:self.presentingViewController
                                  title:nil
                                           subtitle:NSLocalizedString(@"Welcome to Do Good!", nil)
                                   type:TSMessageNotificationTypeSuccess];
        [hud hide:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self.navigationController
                                  title:@"Oops"
                                subtitle:[error localizedDescription]
                                   type:TSMessageNotificationTypeError];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSignInNotification object:self];
        [hud hide:YES];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailField) {
        [_passwordField becomeFirstResponder];
    } else if (textField == _passwordField) {
        [self signIn:textField];
        [textField resignFirstResponder];
    }
    return YES;
}

@end
