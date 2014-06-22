#import "DGUserSettingsViewController.h"
#import "UITextFieldCell.h"
#import "DGUserFindFriendsViewController.h"
#import "DGUserTwitterViewController.h"
#import "DGUserInvitesViewController.h"
#import "DGPhotoPickerViewController.h"
#import <UIImage+Resize.h>
#import <ProgressHUD/ProgressHUD.h>
#import "DGTwitterManager.h"
#import "DGFacebookManager.h"
#import "DGGoodListViewController.h"
#import <SVWebViewController/SVWebViewController.h>

#define full_name_tag 101
#define biography_tag 102
#define location_tag 103
#define email_tag 104
#define phone_tag 105

#define twitter_connected_tag 601
#define facebook_connected_tag 602

#define signOutAlertTag 499
#define disconnectTwitterAlertTag 559
#define disconnectFacebookAlertTag 569

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
    [self setupFooter];

    // social connection status
    twitterManager = [[DGTwitterManager alloc] initWithAppName:APP_NAME];
    facebookManager = [[DGFacebookManager alloc] initWithAppName:APP_NAME];
    [self setSocialConnectionsStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = [DGAppearance barButtonItemWithNoText];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // watch keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[DGTracker sharedTracker] trackScreen:@"User Settings"];
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
    if ([DGUser currentUser].avatar) {
        avatar.image = [DGUser currentUser].avatar;
    } else if ([[DGUser currentUser] avatarURL]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[[DGUser currentUser] avatarURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [avatar setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            avatar.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            DebugLog(@"failed to set avatar");
        }];
    }
}

- (void)setupFooter {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    versionNumber.text = [NSString stringWithFormat:@"%@ (%@)", version, build];
}

#pragma mark - Avatar
- (void)openPhotoPicker {
    [photos openPhotoSheet:avatar.image];
}

- (void)childViewController:(DGPhotoPickerViewController *)viewController didChoosePhoto:(NSDictionary *)dictionary {
    imageToUpload = [dictionary objectForKey:UIImagePickerControllerEditedImage];

    UIImage *currentImage = avatar.image;
    avatar.image = imageToUpload;

    [ProgressHUD show:@"Changing avatar..."];
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil method:RKRequestMethodPUT path:user_update_path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *resizedImage = [imageToUpload resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationHigh];

        NSData *data = UIImageJPEGRepresentation(resizedImage, 0.7);

        [formData appendPartWithFileData:data
                                    name:@"user[avatar]"
                                fileName:@"avatar.jpg"
                                mimeType:@"image/jpeg"];
    }];

    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        [ProgressHUD showSuccess:@"Avatar changed!"];

        DGUser *user = (mappingResult.array)[0];
        [DGUser currentUser].avatar = imageToUpload;
        [DGUser currentUser].avatar_url = user.avatar_url;
        [DGUser assignDefaults];
        avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
        if ([self.delegate respondsToSelector:@selector(childViewControllerDidUpdatePhoto:)]) {
            [self.delegate childViewControllerDidUpdatePhoto:imageToUpload];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        avatar.image = currentImage;
        [TSMessage showNotificationInViewController:self.navigationController title:nil subtitle:NSLocalizedString(@"Avatar upload failed", nil) type:TSMessageNotificationTypeError];
        [ProgressHUD showError:[error localizedDescription]];
    }];

    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}

- (void)removePhoto {
    [[RKObjectManager sharedManager] deleteObject:nil path:user_remove_avatar_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        avatar.image = nil;
        [DGUser currentUser].avatar_url = nil;
        [DGUser currentUser].avatar = nil;
        [DGUser assignDefaults];
        [TSMessage showNotificationInViewController:self.navigationController
                              title:NSLocalizedString(@"Profile photo updated", nil)
                            subtitle:nil
                               type:TSMessageNotificationTypeSuccess];
        if ([self.delegate respondsToSelector:@selector(childViewControllerDidUpdatePhoto:)]) {
            [self.delegate childViewControllerDidUpdatePhoto:nil];
        }
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
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Sign Out", nil];
    alert.tag = signOutAlertTag;
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
        cell.heading.text = @"Your posts";
        cell.textField.userInteractionEnabled = NO;
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (indexPath.row == terms) {
        cell.heading.text = @"Terms of use";
        cell.textField.userInteractionEnabled = NO;
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (indexPath.row == help) {
        cell.heading.text = @"Need help?";
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

- (void)setSocialConnectionsStatus {
    connectedText = @"Connected";
    disconnectedText = @"Not connected";
    if ([[DGUser currentUser].twitter_id isEqualToString:@""] || [DGUser currentUser].twitter_id == nil) {
        twitterConnectedStatus = disconnectedText;
    } else {
        twitterConnectedStatus = connectedText;
    }
    if ([[DGUser currentUser].facebook_id isEqualToString:@""] || [DGUser currentUser].facebook_id == nil) {
        facebookConnectedStatus = disconnectedText;
    } else {
        facebookConnectedStatus = connectedText;
    }
}

- (UITableViewCell *)setupSession:(NSIndexPath *)indexPath {
    UITextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UITextFieldCellIdentifier];
    cell.heading.text = @"Sign Out";
    cell.heading.textColor = ERRONEOUS;
    cell.textField.enabled = NO;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    return settingsNumSections;
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

- (void)loadYourContent {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    controller.user = [DGUser currentUser];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loadTerms {
    NSString *url = @"http://www.dogood.mobi/terms.html";
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:url];
    webViewController.barsTintColor = [UIColor whiteColor];
    [self presentViewController:webViewController animated:YES completion:NULL];
}

- (void)loadHelp {
    NSString *body =[NSString stringWithFormat:@"\n\n\nFrom %@ (%@)", [DGUser currentUser].full_name, [DGUser currentUser].userID];
    [invites setCustomText:body withSubject:@"I need some help!" toRecipient:@"support@dogood.mobi"];
    [invites sendViaEmail:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == accountDetails) {
        if (indexPath.row == resetPassword) {
            [self resetPassword];
        }
        if (indexPath.row == yourContent) {
            [self loadYourContent];
        }
        if (indexPath.row == terms) {
            [self loadTerms];
        }
        if (indexPath.row == help) {
            [self loadHelp];
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
            if ([twitterConnectedStatus isEqualToString:disconnectedText]) {
                [self checkTwitter:YES];
            } else {
                [self disconnectTwitter];
            }
        }
        if (indexPath.row == facebook) {
            if ([facebookConnectedStatus isEqualToString:disconnectedText]) {
                [self checkFacebook:YES];
            } else {
                [self disconnectFacebook];
            }
        }
    }
    if (indexPath.section == session) {
        [self signOut];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)disconnectTwitter {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Disconnect your Twitter account?" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Disconnect", nil];
    alert.tag = disconnectTwitterAlertTag;
    [alert show];
}

- (void)reallyDisconnectTwitter {
    [[DGUser currentUser] saveSocialID:@"" withType:@"twitter" success:^(BOOL success) {
        twitterConnectedStatus = disconnectedText;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        DebugLog(@"failed");
    }];
}

- (void)disconnectFacebook {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Disconnect your Facebook account?" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Disconnect", nil];
    alert.tag = disconnectFacebookAlertTag;
    [alert show];
}

- (void)reallyDisconnectFacebook {
    [[DGUser currentUser] saveSocialID:@"" withType:@"facebook" success:^(BOOL success) {
        facebookConnectedStatus = disconnectedText;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        DebugLog(@"failed");
    }];
}

#pragma mark - Social Network Receivers
- (void)checkTwitter:(BOOL)prompt {
    [twitterManager checkTwitterPostAccessWithSuccess:^(BOOL success, ACAccount *account, NSString *msg) {
        NSString *twitterID = [twitterManager getTwitterIDFromAccount:account];
        [[DGUser currentUser] saveSocialID:twitterID withType:@"twitter" success:^(BOOL success) {
            twitterConnectedStatus = connectedText;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            DebugLog(@"failed");
        }];
    } failure:^(NSError *error) {
        twitterConnectedStatus = disconnectedText;
        if (prompt) {
            [twitterManager promptForPostAccess];
        }
        [self.tableView reloadData];
    }];
}

- (void)checkFacebook:(BOOL)prompt {
    [facebookManager findFacebookFriendsWithSuccess:^(BOOL success, NSArray *msg, ACAccount *account) {
        [facebookManager findFacebookIDForAccount:account withSuccess:^(BOOL success, NSString *facebookID) {
            [[DGUser currentUser] saveSocialID:facebookID withType:@"facebook" success:^(BOOL success) {
                facebookConnectedStatus = connectedText;
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                DebugLog(@"failed");
            }];
        } failure:^(NSError *error) {
            facebookConnectedStatus = disconnectedText;
            DebugLog(@"couldnt find id");
        }];
    } failure:^(NSError *error) {
        facebookConnectedStatus = disconnectedText;
        if (prompt) {
            [facebookManager promptForPostAccess];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if(alertView.tag == signOutAlertTag) {
            [[DGUser currentUser] signOutWithMessage:YES];
        } else if (alertView.tag == disconnectTwitterAlertTag) {
            [self reallyDisconnectTwitter];
        } else if (alertView.tag == disconnectFacebookAlertTag) {
            [self reallyDisconnectFacebook];
        }
    } else {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

@end
