#import "DGSignUpViewController.h"

@interface DGSignUpViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UISwitch *contactable;

@end

@implementation DGSignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
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

- (IBAction)createAccount:(id)sender {
    // can we present a modal and do this in a callback once dismissed?
    [self createAccountWithUsername:self.usernameField.text andEmail:self.emailField.text andPassword:self.passwordField.text andContactable:@(self.contactable.selected)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _usernameField) {
        [_emailField becomeFirstResponder];
    } else if (textField == _emailField) {
        [_passwordField becomeFirstResponder];
    } else if (textField == _passwordField) {
        [self createAccount:textField];
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Create Account
- (void)createAccountWithUsername:(NSString *)username andEmail:(NSString *)email andPassword:(NSString*)password andContactable:(NSNumber *)contactable {
    DGUser *user = [DGUser new];
    user.username = username;
    user.email = email;
    user.password = password;
    // user.contactable = contactable;
    
    [[RKObjectManager sharedManager] postObject:user path:user_registration_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        DGUser * user = (mappingResult.array)[0];
        [DGUser setCurrentUser:user];
        [DGUser signInWasSuccessful];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidCreateAccountNotification object:self];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        [TSMessage showNotificationInViewController:self.presentingViewController
                                  withTitle:nil
                                withMessage:NSLocalizedString(@"Welcome to Do Good!", nil)
                                   withType:TSMessageNotificationTypeSuccess];
        DebugLog(@"success");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"fail");
        [TSMessage showNotificationInViewController:self
                                  withTitle:nil
                                withMessage:[error localizedDescription]
                                   withType:TSMessageNotificationTypeError];
        // [[zoocasaAppDelegate getAppDelegateInstance] showMessage:[error localizedDescription] withTitle:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailCreateAccountNotification object:self];
    }];
}

- (void)checkEmailIsUnique:(NSString *)email {
    // NSDictionary *params = [NSDictionary dictionaryWithObject:email forKey:@"email"];
    // [[RKClient sharedClient] post:@"/users/check_email_unique" params:params delegate:self];
}

@end
