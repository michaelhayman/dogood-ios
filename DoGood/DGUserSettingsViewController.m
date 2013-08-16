#import "DGUserSettingsViewController.h"
#import "UITextFieldCell.h"

@interface DGUserSettingsViewController ()

@end

@implementation DGUserSettingsViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Settings";

    // customize look
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.opaque = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    UINib *nib = [UINib nibWithNibName:@"UITextFieldCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UITextFieldCell"];

    // dismiss keyboard when view tapped
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
}

#pragma mark - Actions
- (void)dismissKeyboard {
    [self.name resignFirstResponder];
}

- (void)signOut {
    [[DGUser currentUser] signOutWithMessage:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SignOut" object:nil];
}

- (void)resetPassword {

}

- (void)searchForFriends {

}

#pragma mark - Update Account
- (void)updateFirstName:(NSString *)firstName andLastName:(NSString *)lastName andContactable:(NSNumber *)contactable {
    DGUser *user;
    user.full_name = firstName;
    user.phone = lastName;
    user.contactable = contactable;
    [[RKObjectManager sharedManager] putObject:user path:user_registration_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [TSMessage showNotificationInViewController:self
                              withTitle:NSLocalizedString(@"Saved!", nil)
                            withMessage:NSLocalizedString(@"Your profile was updated.", nil)
                               withType:TSMessageNotificationTypeSuccess];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateAccountNotification object:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self
                              withTitle:NSLocalizedString(@"Oops", nil)
                            withMessage:NSLocalizedString(@"Couldn't update your profile.", nil)
                               withType:TSMessageNotificationTypeSuccess];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailUpdateAccountNotification object:self];
    }];
}

#pragma mark - UITableView setup methods
- (UITableViewCell *)setupAccountOverview:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITextFieldCell"];
    if (indexPath.row == fullName) {

    }
    if (indexPath.row == biography) {

    }
    return cell;
}

- (UITableViewCell *)setupAccountDetails:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITextFieldCell"];
    if (indexPath.row == email) {
        cell.heading.text = @"Email";
        cell.textField.text = [DGUser currentUser].email;
    }
    if (indexPath.row == phone) {
        cell.heading.text = @"Phone";
        cell.textField.text = [DGUser currentUser].phone;
    }
    if (indexPath.row == resetPassword) {
        cell.heading.text = @"Reset password";
        cell.textField.userInteractionEnabled = NO;
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == yourContent) {
        cell.heading.text = @"Your content";
        cell.textField.userInteractionEnabled = NO;
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (UITableViewCell *)setupFindFriends:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITextFieldCell"];
    if (indexPath.row == bySearching) {
        cell.heading.text = @"Find Friends";
    }
    return cell;
}

- (UITableViewCell *)setupSocialNetworks:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITextFieldCell"];
    if (indexPath.row == twitter) {
        cell.heading.text = @"Twitter";
    }
    return cell;
}

- (UITableViewCell *)setupSession:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UIButtonCell"];
    if (indexPath.row == signOut) {
        UIButton *button = [[UIButton alloc] initWithFrame:cell.frame];
        [button setImage:[UIImage imageNamed:@"SignOutButton"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"SignOutButtonTap"] forState:UIControlStateHighlighted];
    }
    return cell;
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case accountOverview:
            return [self setupAccountOverview:indexPath];
        case accountDetails:
            return [self setupAccountDetails:indexPath];
        case findFriends:
            return [self setupFindFriends:indexPath];
        case socialNetworks:
            return [self setupSocialNetworks:indexPath];
        default:
            return [self setupSession:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == accountOverview && indexPath.section == fullName) {
            return 60;
    } else {
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case accountOverview:
            return accountOverviewNumRows;
        case accountDetails:
            return accountDetailsNumRows;
        case findFriends:
            return findFriendsNumRows;
        case socialNetworks:
            return socialNetworksNumRows;
        default:
            return sessionNumRows;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return settingsNumRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == accountDetails) {
        if (indexPath.row == resetPassword) {
            [self resetPassword];
        }
    }
    if (indexPath.section == findFriends) {
        [self searchForFriends];
    }
    if (indexPath.section == signOut) {
        [self signOut];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}


@end
