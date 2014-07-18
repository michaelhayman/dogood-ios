#import "DGSignUpDetailsViewController.h"
#import "UITextFieldCell.h"

#import <UIImage+Resize.h>
#import <ProgressHUD/ProgressHUD.h>

#define sign_up_overview_cell_tag 100
#define sign_up_email_cell_tag 200
#define sign_up_email_tag 201
#define sign_up_password_cell_tag 300
#define sign_up_password_tag 301
#define sign_up_phone_cell_tag 400
#define sign_up_phone_tag 401

@interface DGSignUpDetailsViewController ()

@end

@implementation DGSignUpDetailsViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"UITextFieldCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UITextFieldCell"];

    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.opaque = NO;

    // self.view.backgroundColor = NEUTRAL_BACKGROUND_COLOUR;

    // self.navigationItem.rightBarButtonItem.tintColor = BUTTON_COLOR;
    // [[UITextField appearance] setBorderStyle:UITextBorderStyleNone];
    // [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"Sign Up - Details"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}


- (void)dealloc {
}

#pragma mark - UITextFieldDelegate & convenience methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == [self textFieldForEmail]) {
        [[self textFieldForPassword] becomeFirstResponder];
    } else if (textField == [self textFieldForPassword]) {
        [[self textFieldForPhone] becomeFirstResponder];
    } else if (textField == [self textFieldForPhone]) {
        [self createAccount:textField];
        [textField resignFirstResponder];
    }
    return YES;
}

- (UITextField *)textFieldForEmail {
    UITextFieldCell *emailCell = (UITextFieldCell *)[tableView viewWithTag:sign_up_email_cell_tag];
    return (UITextField *)[emailCell viewWithTag:sign_up_email_tag];
}

- (UITextField *)textFieldForPassword {
    UITextFieldCell *passwordCell = (UITextFieldCell *)[tableView viewWithTag:sign_up_password_cell_tag];
    return (UITextField *)[passwordCell viewWithTag:sign_up_password_tag];
}

- (UITextField *)textFieldForPhone {
    UITextFieldCell *phoneCell = (UITextFieldCell *)[tableView viewWithTag:sign_up_phone_cell_tag];
    return (UITextField *)[phoneCell viewWithTag:sign_up_phone_tag];
}

#pragma mark - Create Account
- (IBAction)createAccount:(id)sender {
    UITextField *email = [self textFieldForEmail];
    UITextField *password = [self textFieldForPassword];
    UITextField *phone = [self textFieldForPhone];
    DebugLog(@"full name %@ email %@, password %@, phone %@", self.user.full_name, email.text, password.text, phone.text);

    self.user.email = email.text;
    self.user.password = password.text;
    self.user.phone = phone.text;
    bool errors = YES;

    NSString *message;

    if ([self.user.email isEqualToString:@""]) {
        message = @"Set an email address.";
    } else if ([self.user.password isEqualToString:@""]) {
        message = @"Set a password.";
    } else {
        errors = NO;
    }

    if (!errors) {
        [self.view endEditing:YES];
        [ProgressHUD show:@"Creating account..."];

        NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:self.user method:RKRequestMethodPOST path:user_registration_path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (self.user.avatar) {
                UIImage *resizedImage = [self.user.avatar resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationHigh];

                [formData appendPartWithFileData:UIImageJPEGRepresentation(resizedImage, 0.7)
                                            name:@"user[avatar]"
                                        fileName:@"avatar.jpg"
                                        mimeType:@"image/jpeg"];
            }
        }];

        RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            DGUser *user = (mappingResult.array)[0];
            user.password = self.user.password;
            [DGUser setCurrentUser:user];
            [DGUser signInWasSuccessful];
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidCreateAccountNotification object:self];

            if (self.presentingViewController) {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void) {
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                }];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }

            [ProgressHUD showSuccess:NSLocalizedString(@"Welcome to Do Good!", nil)];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"fail");
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailCreateAccountNotification object:self];
            [ProgressHUD showError:[error localizedDescription]];
        }];

        [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
    } else {
        [DGMessage showErrorInViewController:self.navigationController title:@"Error" subtitle:message];
    }
}

- (void)checkEmailIsUnique:(NSString *)email {
    // NSDictionary *params = [NSDictionary dictionaryWithObject:email forKey:@"email"];
    // [[RKClient sharedClient] post:@"/users/check_email_unique" params:params delegate:self];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"UITextFieldCell"];
    if (indexPath.row == email) {
        cell.heading.text = @"Email";
        cell.textField.placeholder = @"example@abc.com";
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.textField.tag = sign_up_email_tag;
        cell.tag = sign_up_email_cell_tag;
        [cell.textField becomeFirstResponder];
    } else if (indexPath.row == password) {
        cell.heading.text = @"Password";
        cell.textField.placeholder = @"at least 8 characters";
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.textField.tag = sign_up_password_tag;
        cell.textField.secureTextEntry = YES;
        cell.tag = sign_up_password_cell_tag;
    } else {
        cell.heading.text = @"Phone";
        cell.textField.placeholder = @"optional";
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.textField.tag = sign_up_phone_tag;
        cell.tag = sign_up_phone_cell_tag;
        cell.textField.returnKeyType = UIReturnKeyDone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textField.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return signUpDetailsNumRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

@end
