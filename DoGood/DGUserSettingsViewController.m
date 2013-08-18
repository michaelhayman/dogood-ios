#import "DGUserSettingsViewController.h"
#import "UITextFieldCell.h"
#import "DGUserSearchViewController.h"

@interface DGUserSettingsViewController ()

@end

@implementation DGUserSettingsViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";

    // customize look
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.opaque = NO;
    // self.view.backgroundColor = GRAYED_OUT;
    self.view.backgroundColor = [UIColor whiteColor];

    UINib *nib = [UINib nibWithNibName:UITextFieldCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:UITextFieldCellIdentifier];

    /*
    UINib *nib = [UINib nibWithNibName:@"UITextFieldCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UITextFieldCell"];
    */

    // dismiss keyboard when view tapped
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
}

#pragma mark - Actions
- (void)dismissKeyboard {
    [self.name resignFirstResponder];
    [self.view endEditing:YES];
}

#define full_name_tag 101
#define biography_tag 102
#define location_tag 103
#define email_tag 104
#define phone_tag 105

- (void)textFieldDidEndEditing:(UITextField *)textField {
    DebugLog(@"ended editing %d", textField.tag);
    if (textField.tag == full_name_tag) {
        DebugLog(@"update full name");
    }
    if (textField.tag == biography_tag) {
        DebugLog(@"update bio");
    }
    if (textField.tag == location_tag) {
        DebugLog(@"update location");
    }
    if (textField.tag == email_tag) {
        DebugLog(@"update email");
    }
    if (textField.tag == phone_tag) {
        DebugLog(@"update phone");
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)signOut {
    [[DGUser currentUser] signOutWithMessage:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SignOut" object:nil];
}

- (void)resetPassword {
    if ([DGUser currentUser].email) {
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/users/password/send" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            DebugLog(@"You have been sent an email with instructions.");
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"Operation failed with error: %@", error);
        }];
    }
}

- (void)searchForFriends {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"User" bundle:nil];
    DGUserSearchViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserSearch"];
    [self.navigationController pushViewController:controller animated:YES];
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
    static NSString *reuseIdentifier = @"OverviewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    UITextField *field;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        field = [[UITextField alloc] initWithFrame:[cell contentView].frame];
        field.delegate = self;
        field.textAlignment = NSTextAlignmentCenter;
        field.font = [UIFont fontWithName:@"Helvetica" size:14];
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        field.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[cell contentView] addSubview:field];
    }
    if (indexPath.row == fullName) {
        field.text = [DGUser currentUser].full_name;
        field.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
        field.placeholder = @"Your name";
        field.tag = full_name_tag;
    }
    if (indexPath.row == biography) {
        field.text = [DGUser currentUser].phone;
        field.placeholder = @"Bio";
        field.tag = biography_tag;
    }
    if (indexPath.row == location) {
        field.text = @"basimah";
        field.placeholder = @"Location";
        field.tag = location_tag;
    }
    return cell;
}

- (UITableViewCell *)setupAccountDetails:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UITextFieldCellIdentifier forIndexPath:indexPath];
    cell.textField.delegate = self;
    if (indexPath.row == email) {
        cell.heading.text = @"Email";
        cell.textField.text = [DGUser currentUser].email;
        cell.textField.tag = email_tag;
    }
    if (indexPath.row == phone) {
        cell.heading.text = @"Phone";
        cell.textField.text = [DGUser currentUser].phone;
        cell.textField.tag = phone_tag;
    }
    if (indexPath.row == resetPassword) {
        cell.heading.text = @"Reset password";
        [cell.heading sizeToFit];
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
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UITextFieldCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == bySearching) {
        cell.heading.text = @"Find Friends";
    }
    if (indexPath.row == byEmail) {
        cell.heading.text = @"Email";
    }
    if (indexPath.row == byText) {
        cell.heading.text = @"Text";
    }
    cell.textField.enabled = NO;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)setupSocialNetworks:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UITextFieldCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == twitter) {
        cell.heading.text = @"Twitter";
    }
    if (indexPath.row == facebook) {
        cell.heading.text = @"Facebook";
    }
    DebugLog(@"bein social");
    return cell;
}

- (UITableViewCell *)setupSession:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"SessionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SessionCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.backgroundView = [UIView new];
        UIButton *button;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = [cell contentView].frame;
        button.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [button setTitle:@"Sign Out" forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"SignOutButton"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"SignOutButtonTap"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:button];
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
    if (indexPath.section == accountOverview && indexPath.row == fullName) {
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
        case session:
            return sessionNumRows;
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return settingsNumRows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionName;

    if (section == accountDetails) {
        sectionName = @"   ACCOUNT";
    }
    if (section == findFriends) {
        sectionName = @"   FIND FRIENDS";
    }
    if (section == socialNetworks) {
        sectionName = @"   SOCIAL NETWORKS";
    }
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 30)];
    sectionHeader.backgroundColor = [UIColor clearColor];
    sectionHeader.font = [UIFont boldSystemFontOfSize:14];
    sectionHeader.textColor = [UIColor blackColor];
    sectionHeader.text = sectionName;

    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case accountOverview:
            return @"";
        case accountDetails:
            return @"ACCOUNT";
        case findFriends:
            return @"FRIENDS";
        case socialNetworks:
            return @"SOCIAL NETWORKS";
        case session:
            return @"";
        default:
            return @"";
    }
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == accountDetails) {
        if (indexPath.row == resetPassword) {
            [self resetPassword];
        }
    }
    if (indexPath.section == findFriends) {
        if (indexPath.row == bySearching) {
            [self searchForFriends];
        }
    }
    /*
    if (indexPath.section == session) {
        if (indexPath.row == signOut) {
            [self signOut];
        }
    }
    */
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}


@end
