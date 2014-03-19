#import "DGUserSettingsViewController.h"
#import "UITextFieldCell.h"
#import "DGUserFindFriendsViewController.h"
#import "DGUserTwitterViewController.h"
#import "DGUserInvitesViewController.h"
#import "DGPhotoPickerViewController.h"
#import <UIImage+Resize.h>
#import <MBProgressHUD.h>
#import "DGTwitterManager.h"
#import "DGFacebookManager.h"

#define full_name_tag 101
#define biography_tag 102
#define location_tag 103
#define email_tag 104
#define phone_tag 105

#define twitter_connected_tag 601
#define facebook_connected_tag 602

@interface DGUserSettingsViewController ()

@end

@implementation DGUserSettingsViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Settings"];

    // customize look
    /*
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.opaque = NO;
    self.view.backgroundColor = NEUTRAL_BACKGROUND_COLOUR;
    */

    UINib *nib = [UINib nibWithNibName:UITextFieldCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:UITextFieldCellIdentifier];

    // invites
    invites = [[DGUserInvitesViewController alloc] init];
    invites.parent = self;

    // photos
    photos = [[DGPhotoPickerViewController alloc] init];
    photos.parent = self;
    photos.delegate = self;

    // setup avatar
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    avatar.backgroundColor = COLOUR_OFF_WHITE;
    UITapGestureRecognizer* avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoPicker)];
    [avatar setUserInteractionEnabled:YES];
    [avatar addGestureRecognizer:avatarGesture];
    [self setupHeader];

    // social connection status
    twitterManager = [[DGTwitterManager alloc] initWithAppName:APP_NAME];
    facebookManager = [[DGFacebookManager alloc] initWithAppName:APP_NAME];
    twitterConnectedStatus = @"-";
    facebookConnectedStatus = @"-";
    [self checkTwitter:NO];
    [self checkFacebook:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // watch keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupHeader {
    if ([[DGUser currentUser] avatarURL]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[[DGUser currentUser] avatarURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [avatar setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            avatar.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            DebugLog(@"failed to set avatar");
        }];
    }
}

#pragma mark - Avatar
- (void)openPhotoPicker {
    [photos openPhotoSheet:avatar.image];
}

- (void)childViewController:(DGPhotoPickerViewController *)viewController didChoosePhoto:(NSDictionary *)dictionary {
    imageToUpload = [dictionary objectForKey:UIImagePickerControllerEditedImage];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Changing avatar...";
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil method:RKRequestMethodPUT path:user_update_path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

            [formData appendPartWithFileData:UIImagePNGRepresentation(imageToUpload)
                                        name:@"user[avatar]"
                                    fileName:@"avatar.png"
                                    mimeType:@"image/png"];
    }];

    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"Completed";
        [hud hide:YES];

        avatar.image = imageToUpload;
        DGUser *user = (mappingResult.array)[0];
        [DGUser currentUser].avatar_url = user.avatar_url;
        [DGUser assignDefaults];
        avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
        // [avatar bringSubviewToFront:avatarOverlay];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateAccountNotification object:nil];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self.navigationController title:nil subtitle:NSLocalizedString(@"Avatar upload failed", nil) type:TSMessageNotificationTypeError];
        [hud hide:YES];
    }];

    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}

- (void)removePhoto {
    [[RKObjectManager sharedManager] deleteObject:nil path:user_remove_avatar_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        avatar.image = nil;
        [DGUser currentUser].avatar_url = nil;
        [DGUser currentUser].image = nil;
        [DGUser assignDefaults];
        [TSMessage showNotificationInViewController:self.navigationController
                              title:NSLocalizedString(@"Profile photo updated", nil)
                            subtitle:nil
                               type:TSMessageNotificationTypeSuccess];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateAccountNotification object:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self.navigationController
                              title:NSLocalizedString(@"Oops", nil)
                            subtitle:NSLocalizedString(@"Couldn't remove your photo.", nil)
                               type:TSMessageNotificationTypeError];
    }];
}

#pragma mark - UITextFieldDelegate methods
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == full_name_tag) {
        if (![textField.text isEqualToString:[DGUser currentUser].full_name]) {
            DGUser *user = [DGUser new];
            user.full_name = textField.text;
            [[RKObjectManager sharedManager] putObject:user path:user_update_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [DGUser currentUser].full_name = textField.text;
                [DGUser assignDefaults];
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateAccountNotification object:nil];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [TSMessage showNotificationInViewController:self.navigationController
                                      title:NSLocalizedString(@"Oops", nil)
                                    subtitle:NSLocalizedString(@"Couldn't update your name.", nil)
                                       type:TSMessageNotificationTypeError];
            }];
        } else {
            DebugLog(@"don't update full name");
        }
    }
    if (textField.tag == biography_tag) {
        if (![textField.text isEqualToString:[DGUser currentUser].biography]) {
            DGUser *user = [DGUser new];
            user.biography = textField.text;
            [[RKObjectManager sharedManager] putObject:user path:user_update_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [DGUser currentUser].biography = textField.text;
                [DGUser assignDefaults];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [TSMessage showNotificationInViewController:self.navigationController
                                      title:NSLocalizedString(@"Oops", nil)
                                    subtitle:NSLocalizedString(@"Couldn't update your biography.", nil)
                                       type:TSMessageNotificationTypeError];
            }];
        } else {
            DebugLog(@"don't update bio");
        }
    }
    if (textField.tag == location_tag) {
        if (![textField.text isEqualToString:[DGUser currentUser].location]) {
            DGUser *user = [DGUser new];
            user.location = textField.text;
            [[RKObjectManager sharedManager] putObject:user path:user_update_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [DGUser currentUser].location = textField.text;
                [DGUser assignDefaults];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [TSMessage showNotificationInViewController:self.navigationController
                                      title:NSLocalizedString(@"Oops", nil)
                                    subtitle:NSLocalizedString(@"Couldn't update your biography.", nil)
                                       type:TSMessageNotificationTypeError];
            }];
        } else {
            DebugLog(@"don't update location");
        }
    }
    if (textField.tag == email_tag) {
        DebugLog(@"prob won't let em update email");
    }
    if (textField.tag == phone_tag) {
        if (![textField.text isEqualToString:[DGUser currentUser].phone]) {
            DGUser *user = [DGUser new];
            user.phone = textField.text;
            [[RKObjectManager sharedManager] putObject:user path:user_update_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [DGUser currentUser].phone = textField.text;
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [TSMessage showNotificationInViewController:self.navigationController
                                      title:NSLocalizedString(@"Oops", nil)
                                    subtitle:NSLocalizedString(@"Couldn't update your biography.", nil)
                                       type:TSMessageNotificationTypeError];
            }];
        } else {
            DebugLog(@"don't update phone");
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard handler
- (void)keyboardWillShow:(NSNotification *)notification {
    dismissTap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:dismissTap];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.view removeGestureRecognizer:dismissTap];
}

#pragma mark - Actions
- (void)signOut {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Are you sure you want to sign out?"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Yes", @"No", nil];
    alert.cancelButtonIndex = 1;
    alert.tag = 59;
    [alert show];
}

- (void)resetPassword {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserTwitterViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UpdatePassword"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)twitter {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserTwitterViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Twitter"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)findFriendsSearch {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserFindFriendsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FindFriends"];
    [self.navigationController pushViewController:controller animated:YES];
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
        field.text = [DGUser currentUser].biography;
        field.placeholder = @"About me";
        field.tag = biography_tag;
    }
    if (indexPath.row == location) {
        field.text = [DGUser currentUser].location;
        field.placeholder = @"Location";
        field.tag = location_tag;
    }
    return cell;
}

- (UITableViewCell *)setupAccountDetails:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UITextFieldCellIdentifier];
    cell.textField.delegate = self;
    if (indexPath.row == email) {
        cell.heading.text = @"Email";
        cell.textField.text = [DGUser currentUser].email;
        cell.textField.textColor = [UIColor lightGrayColor];
        cell.textField.tag = email_tag;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.userInteractionEnabled = NO;
    }
    if (indexPath.row == phone) {
        cell.heading.text = @"Phone";
        cell.textField.text = [DGUser currentUser].phone;
        cell.textField.tag = phone_tag;
        cell.textField.placeholder = @"e.g. (555) 419-3902";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == resetPassword) {
        cell.heading.text = @"Reset password";
        [cell.heading sizeToFit];
        [cell.textField removeFromSuperview];
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (indexPath.row == yourContent) {
        cell.heading.text = @"Your content";
        cell.textField.userInteractionEnabled = NO;
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.userInteractionEnabled = YES;
    return cell;
}

- (UITableViewCell *)setupFindFriends:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UITextFieldCellIdentifier];
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
        cell.textField.tag = twitter_connected_tag;
        cell.textField.text = twitterConnectedStatus;
    }
    if (indexPath.row == facebook) {
        cell.heading.text = @"Facebook";
        cell.textField.text = facebookConnectedStatus;
        cell.textField.tag = facebook_connected_tag;
    }
    cell.textField.userInteractionEnabled = NO;
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
        // button.frame = CGRectMake(10, 0, 300, button.frame.size.width);
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == accountDetails || section == socialNetworks || section == findFriends) {
        return 30.0;
    } else {
        return 0.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == accountDetails) {
        if (indexPath.row == resetPassword) {
            [self resetPassword];
        }
    }
    if (indexPath.section == findFriends) {
        if (indexPath.row == bySearching) {
            [self findFriendsSearch];
        }
        if (indexPath.row == byText) {
            [invites setInviteText];
            [invites sendViaText:nil];
        }
        if (indexPath.row == byEmail) {
            [invites setInviteText];
            [invites sendViaEmail:nil];
        }
    }
    if (indexPath.section == socialNetworks) {
        if (indexPath.row == twitter) {
            [self checkTwitter:YES];
        }
        if (indexPath.row == facebook) {
            [self checkFacebook:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Social Network Receivers
- (void)checkTwitter:(BOOL)prompt {
    [twitterManager checkTwitterPostAccessWithSuccess:^(BOOL success, NSString *msg) {
        twitterConnectedStatus = @"Connected";
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        twitterConnectedStatus = @"Not connected";
        if (prompt) {
            [twitterManager promptForPostAccess];
        }
        [self.tableView reloadData];
    }];
}

- (void)checkFacebook:(BOOL)prompt {
    [facebookManager checkFacebookPostAccessWithSuccess:^(BOOL success, NSString *msg) {
        facebookConnectedStatus = @"Connected";
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        facebookConnectedStatus = @"Not connected";
        if (prompt) {
            [facebookManager promptForPostAccess];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 59) {
        if(buttonIndex == 0) {
            [[DGUser currentUser] signOutWithMessage:YES];
        } else {
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        }
    }
}

@end
