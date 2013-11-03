#import "DGUpdatePasswordViewController.h"

@interface DGUpdatePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *currentPassword;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmation;

@end

@implementation DGUpdatePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popController)
                                                 name:DGUserDidUpdatePasswordNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)popController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updatePassword:(id)sender {
    [self updatePassword:self.currentPassword.text toPassword:self.password.text withConfirmedPassword:self.passwordConfirmation.text];
}

- (void)updatePassword:(NSString *)currentPassword toPassword:(NSString*)password withConfirmedPassword:(NSString *)passwordConfirmation {
    NSMutableDictionary *user = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentPassword, @"current_password", password, @"password", passwordConfirmation, @"password_confirmation", nil];
    user[@"user"] = params;
    
    [[RKObjectManager sharedManager] putObject:user path:user_update_password_path parameters:user success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [DGUser setNewPassword:user[@"user"][@"password"]];
        DGUser * user = (mappingResult.array)[0];

        [TSMessage showNotificationInViewController:self.navigationController
                                  title:NSLocalizedString(@"Password updated.", nil)
                                           subtitle:user.message
                                   type:TSMessageNotificationTypeSuccess];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdatePasswordNotification object:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self.navigationController
                                  title:NSLocalizedString(@"Couldn't save password.", nil)
                                subtitle:[error localizedDescription]
                                   type:TSMessageNotificationTypeError];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailUpdatePasswordNotification object:self];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _currentPassword) {
        [_password becomeFirstResponder];
    } else if (textField == _password) {
        [_passwordConfirmation becomeFirstResponder];
    } else if (textField == _passwordConfirmation) {
        [self updatePassword:textField];
        [textField resignFirstResponder];
    }
    return YES;
}

@end
