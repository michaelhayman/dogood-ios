#import "DGSignInViewController.h"

@interface DGSignInViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation DGSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)forgotPassword:(id)sender {
    UIStoryboard * users = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    UIViewController * controller = [users instantiateViewControllerWithIdentifier:@"forgotPassword"];
    // [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)signIn:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    DebugLog(@"getting hit");
    // [self signInWithEmail:self.emailField.text andPassword:self.passwordField.text showMessage:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)signInWithEmail:(NSString *)email andPassword:(NSString *)password showMessage:(BOOL)message {
    DGUser *user;
    user.email = email;
    user.password = password;

    [[RKObjectManager sharedManager] postObject:user path:user_session_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		[DGUser signInWasSuccessful];
        [DGUser setCurrentUser:user];

        if (message == YES) {
            DebugLog(@"success");
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (message == YES) {
            DebugLog(@"error %@", [error localizedDescription]);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSignInNotification object:self];
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
