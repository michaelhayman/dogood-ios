#import "DGUserSettingsViewController.h"
#import "UITextFieldCell.h"
#import "DGUserFindFriendsViewController.h"
#import "DGUserTwitterViewController.h"
#import "DGUserInvitesViewController.h"
#import "DGPhotoPickerViewController.h"
#import <UIImage+Resize.h>
#import <MBProgressHUD.h>

// #import "ThirdParties.h"

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

    // watch for events to change settings values
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterConnected:) name:DGUserDidCheckIfTwitterIsConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookConnected:) name:DGUserDidCheckIfFacebookIsConnected object:nil];
    // watch keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // invites
    invites = [[DGUserInvitesViewController alloc] init];
    invites.parent = self;

    // photos
    photos = [[DGPhotoPickerViewController alloc] init];
    photos.parent = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatar:) name:DGUserDidAddPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAvatar) name:DGUserDidRemovePhotoNotification object:nil];

    // setup avatar
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    avatar.backgroundColor = COLOUR_OFF_WHITE;
    UITapGestureRecognizer* avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoPicker)];
    [avatar setUserInteractionEnabled:YES];
    [avatar addGestureRecognizer:avatarGesture];
    [self setupHeader];

    // connection status
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    // [ThirdParties checkTwitterAccess:NO];
    // [ThirdParties checkFacebookAccess];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidAddPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidRemovePhotoNotification object:nil];
}

- (void)setupHeader {
    DebugLog(@"setting header %@", [DGUser currentUser].avatar);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[DGUser currentUser].avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [avatar setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        DebugLog(@"set avatar");
        avatar.image = image;
        // not sure I need this
        // avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        DebugLog(@"failed to set avatar");
    }];
    DebugLog(@"gestures");
}

#pragma mark - Avatar
- (void)openPhotoPicker {
    [photos openPhotoSheet:avatar.image];
}

- (void)uploadAvatar:(NSNotification *)notification  {
    DebugLog(@"uploading");
    imageToUpload = [[notification userInfo] objectForKey:UIImagePickerControllerEditedImage];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
        [DGUser currentUser].avatar = user.avatar;
        [DGUser assignDefaults];
        avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
        // [avatar bringSubviewToFront:avatarOverlay];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateAccountNotification object:nil];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self.navigationController
                                  title:nil
                                subtitle:NSLocalizedString(@"Avatar upload failed", nil)
                                   type:TSMessageNotificationTypeError];
        [hud hide:YES];
    }];

    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}

- (void)deleteAvatar {
    [[RKObjectManager sharedManager] deleteObject:nil path:user_remove_avatar_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        avatar.image = nil;
        [DGUser currentUser].avatar = nil;
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
            DebugLog(@"update full name");
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
            DebugLog(@"update location");
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
            DebugLog(@"update phone");
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
    DebugLog(@"reset password");
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

- (void)facebook {
    DebugLog(@"Debugging: %@", @"facebook");
}

- (void)findFriendsSearch {
    DebugLog(@"Debugging: %@", @"find friends search");

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
    DebugLog(@"selected a row");
    if (indexPath.section == accountDetails) {
        if (indexPath.row == resetPassword) {
            DebugLog(@"trying to reset password");
            [self resetPassword];
        }
    }
    if (indexPath.section == findFriends) {
        DebugLog(@"find friends");
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
            // [ThirdParties checkTwitterAccess:YES];
        }
        if (indexPath.row == facebook) {
            if ([facebookConnectedStatus isEqualToString:@"Connected"]) {
                // [ThirdParties removeFacebookAccess];
            } else {
                // [ThirdParties checkFacebookAccessForPosting];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Social Network Receivers
- (void)twitterConnected:(NSNotification *)notification {
    NSNumber* connected = [[notification userInfo] objectForKey:@"connected"];
    if ([connected boolValue]) {
        twitterConnectedStatus = @"Connected";
    } else {
        twitterConnectedStatus = @"Not connected";
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)facebookConnected:(NSNotification *)notification {
    NSNumber* connected = [[notification userInfo] objectForKey:@"connected"];
    DebugLog(@"connected to fb? %@", connected);
    if ([connected boolValue]) {
        facebookConnectedStatus = @"Connected";
    } else {
        facebookConnectedStatus = @"Not connected";
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
