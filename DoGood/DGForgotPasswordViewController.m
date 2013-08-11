#import "DGForgotPasswordViewController.h"

@interface DGForgotPasswordViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation DGForgotPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popController)
                                                 name:DGUserDidSendPasswordNotification
                                               object:nil];
}

- (void)popController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (IBAction)forgotPassword:(id)sender {
    DebugLog(@"email %@", self.emailField.text);
    [self sendPasswordToEmail:self.emailField.text];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
                                  withTitle:NSLocalizedString(@"Password sent.", nil)
                                withMessage:user.message
                                   withType:TSMessageNotificationTypeSuccess];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [TSMessage showNotificationInViewController:self
                                  withTitle:NSLocalizedString(@"Password not sent.", nil)
                                withMessage:[error description]
                                   withType:TSMessageNotificationTypeError];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSendPasswordNotification object:nil];
    }];
}

@end
