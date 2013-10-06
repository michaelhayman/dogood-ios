#import "DGSignInViewController.h"

@interface DGSignInViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation DGSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sign In";
    self.navigationItem.title = self.title;
    self.navigationItem.hidesBackButton = NO;
    // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)signIn:(id)sender {
    [self signInWithEmail:self.emailField.text orUsername:self.emailField.text andPassword:self.passwordField.text showMessage:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)signInWithEmail:(NSString *)email orUsername:(NSString *)username andPassword:(NSString *)password showMessage:(BOOL)message {
    DGUser *user = [DGUser new];
    user.email = email;
    user.username = username;
    user.password = password;
    DebugLog(@"usreage %@", user);

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
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self
                                  title:nil
                                subtitle:[error localizedDescription]
                                   type:TSMessageNotificationTypeError];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSignInNotification object:self];
        DebugLog(@"user %@", user);
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
