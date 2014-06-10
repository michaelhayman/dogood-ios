#import "DGForgotPasswordViewController.h"

@interface DGForgotPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation DGForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Forgot Password";
    self.emailField.text = self.signInEmail;
    [self.emailField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popController) name:DGUserDidSendPasswordNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSendPasswordNotification object:nil];
}

- (void)popController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(childViewController:didReceiveEmail:)]) {
        [self.delegate childViewController:self didReceiveEmail:self.emailField.text];
    }
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (IBAction)forgotPassword:(id)sender {
    DebugLog(@"email %@", self.emailField.text);
    [self sendPasswordToEmail:self.emailField.text];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailField) {
        [self forgotPassword:textField];
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)sendPasswordToEmail:(NSString*)email {
    DGUser *user = [DGUser new];
    user.email = email;
    user.password = nil;

    [[RKObjectManager sharedManager] postObject:user path:user_password_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        DGUser *user = (mappingResult.array)[0];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSendPasswordNotification object:nil];
        DebugLog(@"password sent %@ %@", self.parentViewController, self.navigationController.parentViewController);
        [TSMessage showNotificationInViewController:self.parentViewController
                                  title:NSLocalizedString(@"Password sent.", nil)
                                           subtitle:user.message
                                   type:TSMessageNotificationTypeSuccess];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [TSMessage showNotificationInViewController:self.navigationController
                                  title:NSLocalizedString(@"Password not sent.", nil)
                                subtitle:[error localizedDescription]
                                   type:TSMessageNotificationTypeError];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSendPasswordNotification object:nil];
    }];
}

@end
