#import "DGUserTwitterViewController.h"

@interface DGUserTwitterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation DGUserTwitterViewController

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

- (IBAction)signIn:(id)sender {
    [self signInWithEmail:self.emailField.text orUsername:self.emailField.text andPassword:self.passwordField.text showMessage:YES];
}

- (void)dealloc {
}

- (void)signInWithEmail:(NSString *)email orUsername:(NSString *)username andPassword:(NSString *)password showMessage:(BOOL)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidConnectToTwitter object:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
