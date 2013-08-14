#import "DGSignUpViewController.h"
#import "SignUpOverviewCell.h"

@interface DGSignUpViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UISwitch *contactable;

@end

@implementation DGSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"SignUpOverviewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"SignUpOverview"];


    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.opaque = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    [[UITextField appearance] setBorderStyle:UITextBorderStyleNone];
    [self registerForKeyboardNotifications];
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

#define sign_up_overview_cell_tag 100
#define sign_up_email_cell_tag 200
#define sign_up_email_tag 201
#define sign_up_name_cell_tag 300
#define sign_up_name_tag 301
#define sign_up_phone_cell_tag 400
#define sign_up_phone_tag 401
- (IBAction)createAccount:(id)sender {
    SignUpOverviewCell *cell = (SignUpOverviewCell *)[tableView viewWithTag:sign_up_overview_cell_tag];
    NSString *username = cell.username.text;
    NSString *password = cell.password.text;
    UITableViewCell *emailCell = (UITableViewCell *)[tableView viewWithTag:sign_up_email_cell_tag];
    UITextField *email = (UITextField *)[emailCell viewWithTag:sign_up_email_tag];
    UITableViewCell *nameCell = (UITableViewCell *)[tableView viewWithTag:sign_up_name_cell_tag];
    UITextField *name = (UITextField *)[nameCell viewWithTag:sign_up_name_tag];
    UITableViewCell *phoneCell = (UITableViewCell *)[tableView viewWithTag:sign_up_phone_cell_tag];
    UITextField *phone = (UITextField *)[phoneCell viewWithTag:sign_up_phone_tag];
    DebugLog(@"email %@, username %@, password %@ name %@ phone %@", email.text, username, password, name.text, phone.text);
    /*
    self.good.shareDoGood = doGood.share.on;
    UITableViewCell *twitter = (GoodShareCell *)[self.tableView viewWithTag:sign_up_username_cell_tag];
    self.good.shareTwitter = twitter.share.on;
    UITableViewCell *facebook = (GoodShareCell *)[self.tableView viewWithTag:sign_up_phone_cell_tag];
    self.good.shareFacebook = facebook.share.on;
    */

    // [self createAccountWithUsername:username email:email.text password:password contactable:@(self.contactable.selected) name:name.text andPhone:phone.text];
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
- (void)createAccountWithUsername:(NSString *)username email:(NSString *)email password:(NSString*)password contactable:(NSNumber *)contactable name:(NSString *)name andPhone:(NSString *)phone {
    DGUser *user = [DGUser new];
    user.username = username;
    user.email = email;
    user.password = password;
    user.name = name;
    user.phone = phone;
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
#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == signUpOverview) {
        SignUpOverviewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"SignUpOverview"];
        return cell;
    } else {
        if (indexPath.row == email) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Email"];
            return cell;
        } else if (indexPath.row == name) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Name"];
            return cell;
        } else {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Phone"];
            return cell;
        }
    }
    // all this stuff can move to the cell...
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == signUpOverview) {
        return 80;
    } else {
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if (section == signUpOverview) {
        return 1;
    } else {
        return signUpDetailsNumRows;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == details) {
        return @"ACCOUNT";
    } else {
        return nil;
    }
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    DebugLog(@"kb shown");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = activeField.frame.origin;
    origin.y -= tableView.contentOffset.y;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y+(aRect.size.height));
        [tableView setContentOffset:scrollPoint animated:YES];
    }
}
/*
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = activeField.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [activeField.superview setFrame:bkgndRect];
    [tableView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-kbSize.height) animated:YES];
}
*/
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    DebugLog(@"kb hidden");
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    DebugLog(@"began editing");
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

@end
