#import "DGSignInViewController.h"
#import <ProgressHUD/ProgressHUD.h>

@interface DGSignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation DGSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.emailField becomeFirstResponder];
    if (DEVELOPMENT) {
        self.emailField.text = @"michael@springbox.ca";
        self.passwordField.text = @"heyheyhey";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)signIn:(id)sender {
    [self signInWithEmail:self.emailField.text orUsername:self.emailField.text andPassword:self.passwordField.text showMessage:YES];
}

- (void)childViewController:(DGForgotPasswordViewController* )viewController didReceiveEmail:(NSString *)email {
    self.emailField.text = email;
}

- (IBAction)forgotPassword:(id)sender {
    DGForgotPasswordViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPassword"];
    controller.signInEmail = self.emailField.text;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)dealloc {
}

- (void)signInWithEmail:(NSString *)email orUsername:(NSString *)username andPassword:(NSString *)password showMessage:(BOOL)message {
    DGUser *user = [DGUser new];
    user.email = email;
    user.password = password;
    [ProgressHUD show:@"Signing in..."];
    [self.view endEditing:YES];

    [[RKObjectManager sharedManager] postObject:user path:user_session_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [DGUser setCurrentUser:user];
		[DGUser signInWasSuccessful];

        [ProgressHUD showSuccess:@"Welcome back!"];

        if (self.presentingViewController) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            }];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSignInNotification object:self];
        [ProgressHUD showError:[error localizedDescription]];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
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
