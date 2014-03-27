#import "DGUserProfileViewController.h"
#import "DGWelcomeViewController.h"
#import "DGUserSettingsViewController.h"
#import "GoodTableView.h"
#import "DGUserListViewController.h"
#import "DGUserFindFriendsViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "DGFollow.h"
#import "DGReport.h"
#import "DGUserInvitesViewController.h"
#import "DGAppearance.h"
#import "GoodTableView.h"
#import <SAMLoadingView/SAMLoadingView.h>
#import "AuthenticateView.h"
#import <ProgressHUD/ProgressHUD.h>

@interface DGUserProfileViewController ()

@end

@implementation DGUserProfileViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // one time events
    [self registerNotifications];
    self.view.backgroundColor = [UIColor whiteColor];

    loadingView = [[SAMLoadingView alloc] initWithFrame:self.view.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:loadingView];

    authenticateView.navigationController = self.navigationController;
    [self.view bringSubviewToFront:authenticateView];
    authenticateView.hidden = YES;

    // setup following / followers text
    UITapGestureRecognizer* followersGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowers)];
    [followers setUserInteractionEnabled:YES];
    [followers addGestureRecognizer:followersGesture];

    UITapGestureRecognizer* followingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowing)];
    [following setUserInteractionEnabled:YES];
    [following addGestureRecognizer:followingGesture];

    avatar.contentMode = UIViewContentModeScaleAspectFit;

    // get good list
    goodTableView.navigationController = self.navigationController;
    goodTableView.parent = self;
    [goodTableView setupRefresh];

    invites = [[DGUserInvitesViewController alloc] init];
    invites.parent = (UIViewController *)self;

    name.font = PROFILE_FONT;
    name.textColor = [UIColor whiteColor];

    [self initialize];
}

- (BOOL)isOwnProfile {
    return [[DGUser currentUser] isSignedIn] && [self.userID isEqualToNumber:[DGUser currentUser].userID];
}

- (void)setupOwnProfile {
    authenticateView.hidden = YES;
    DebugLog(@"from menu");
    self.userID = [DGUser currentUser].userID;
    [self setupMenuTitle:@"You"];
    [avatarOverlay setUserInteractionEnabled:YES];
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(openSettings)];
    [avatarOverlay addGestureRecognizer:tap];
    DebugLog(@"menu doesn't really help; because we have to checknot from menu");

    [self setupOwnProfileButtons];
    // name.text = [DGUser currentUser].full_name;

    [self getProfile];
}

- (void)setupProfile {
    [self setupMenuTitle:user.full_name];

    [self setupProfileButtons];
    if (!profileLoaded) {
        [self getProfile];
    }
}

- (void)setupAuth {
    [self setupMenuTitle:@"Join Do Good"];
    authenticateView.hidden = NO;
    [self removeMoreOptions];
}

- (void)initialize {
    if (self.fromMenu) {
        if ([[DGUser currentUser] isSignedIn]) {
            [self setupOwnProfile];
        } else {
            [self setupAuth];
        }
    } else {
        if ([self isOwnProfile]) {
            [self setupOwnProfile];
        } else {
            [self setupProfile];
        }
    }

    [self getUserGood];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.fromMenu) {
         [self addMenuButton:@"MenuFromProfileIconTap" withTapButton:@"MenuFromProfileIcon"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialize) name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialize) name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialize) name:DGUserDidUpdateAccountNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialize) name:DGUserDidUpdateFollowingsNotification object:nil];
}

- (void)deregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidUpdateAccountNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidUpdateFollowingsNotification object:nil];
}

- (void)dealloc {
    DebugLog(@"dealloc %@", [self class]);
    [self deregisterNotifications];
}

#pragma mark - Tabs
- (void)setupTabs {
    [goodsButton addTarget:self action:@selector(getUserGood) forControlEvents:UIControlEventTouchUpInside];
    [goodsButton setTitle:[NSString stringWithFormat:@"%@ Nominations", user.posted_or_followed_goods_count] forState:UIControlStateNormal];
    [goodsButton setTitle:[NSString stringWithFormat:@"%@ Nominations", user.posted_or_followed_goods_count] forState:UIControlStateSelected];
    [likesButton addTarget:self action:@selector(getUserLikes) forControlEvents:UIControlEventTouchUpInside];
    [likesButton setTitle:[NSString stringWithFormat:@"%@ Likes", user.liked_goods_count] forState:UIControlStateNormal];
}

- (void)resetProfile {
    self.userID = nil;
}

#pragma mark - User retrieval
- (void)getProfile {
    DebugLog(@"profile called");

    dispatch_async(dispatch_get_main_queue(), ^{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/users/%@", self.userID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        user = [DGUser new];
        user = mappingResult.array[0];

        followers.text = [NSString stringWithFormat:@"%@ follower%@", user.followers_count, [DGAppearance pluralForCount:user.followers_count]];
        [followers sizeToFit];
        following.text = [NSString stringWithFormat:@"%@ following", user.following_count];
        [following sizeToFit];

        name.text = user.full_name;

        if ([user.current_user_following boolValue] == YES) {
            centralButton.selected = YES;
            [centralButton setBackgroundImage:[UIImage imageNamed:@"ProfileFollowingButtonTap"] forState:UIControlStateHighlighted];
            [centralButton setTitle:@"Following" forState:UIControlStateNormal];
        } else {
            DebugLog(@"not following");
        }

        [self setupTabs];

        if (!avatar.image) {
            if ([user avatarURL]) {
                NSURLRequest *request = [NSURLRequest requestWithURL:[user avatarURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
                [avatar setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    avatar.image = image;
                    if ([self isOwnProfile]) {
                       avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
                        [avatar bringSubviewToFront:avatarOverlay];
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    DebugLog(@"Failed to retrieve avatar.");
                }];
            }
        }
        [loadingView removeFromSuperview];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [loadingView removeFromSuperview];
        // [ProgressHUD showError:[error localizedDescription]];
    }];

    });
}

- (void)toggleFollow {
    if (centralButton.isSelected == NO) {
        [self increaseFollow];

        [DGFollow followType:@"User" withID:user.userID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
            DebugLog(@"%@", msg);
        } failure:^(NSError *error) {
            [self decreaseFollow];
            DebugLog(@"failed to remove follow");
        }];
    } else {
        [self decreaseFollow];

        [DGFollow unfollowType:@"User" withID:user.userID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
            DebugLog(@"%@", msg);
        } failure:^(NSError *error) {
            [self increaseFollow];
            DebugLog(@"failed to remove follow");
        }];
    }
}

- (void)increaseFollow {
    [centralButton setSelected:YES];
}

- (void)decreaseFollow {
    [centralButton setSelected:NO];
}

- (void)openSettings {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserSettingsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Actions
- (IBAction)findFriends:(id)sender {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserFindFriendsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FindFriends"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)openActionMenu:(id)sender {
    [moreOptionsSheet showInView:self.navigationController.view];
}

- (void)setupOwnProfileButtons {
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Find Friends" style: UIBarButtonItemStylePlain target:self action:@selector(findFriends:)];
    [centralButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    [centralButton setTitle:@"Settings" forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = connectButton;
}

- (void)setupProfileButtons {
    [centralButton setBackgroundImage:[UIImage imageNamed:@"ProfileFollowButton"] forState:UIControlStateNormal];
    [centralButton setBackgroundImage:[UIImage imageNamed:@"ProfileFollowButtonTap"] forState:UIControlStateHighlighted];
    [centralButton setBackgroundImage:[UIImage imageNamed:@"ProfileFollowingButton"] forState:UIControlStateSelected];
    [centralButton setTitle:@"Follow" forState:UIControlStateNormal];
    [centralButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [centralButton addTarget:self action:@selector(toggleFollow) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:@"..." style: UIBarButtonItemStylePlain target:self action:@selector(openActionMenu:)];
    self.navigationItem.rightBarButtonItem = connectButton;

    moreOptionsSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Report user"
                                       otherButtonTitles:@"Share profile", nil];
    [moreOptionsSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    moreOptionsSheet.delegate = self;

    [self setupShareOptions];
}

- (void)removeMoreOptions {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)setupShareOptions {
    shareOptionsSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Text message", @"Email", nil];
    [shareOptionsSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    shareOptionsSheet.delegate = self;
}

- (void)openShareOptions {
    [shareOptionsSheet showInView:self.navigationController.view];
}

#pragma mark - UIAlertViewDelegate methods
#define share_button 1
#define text_message_button 0
#define email_button 1
#define facebook_button 2
#define twitter_button 3
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet == moreOptionsSheet) {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [self reportUser];
            } else if (buttonIndex == share_button) {
                [self openShareOptions];
            }
        } else if (actionSheet == shareOptionsSheet) {
            NSString *text = [NSString stringWithFormat:@"Check out this good person! dogood://users/%@", self.userID];
            if (buttonIndex == text_message_button) {
                [invites setCustomText:text withSubject:nil];
                [invites sendViaText:nil];
            } else if (buttonIndex == email_button) {
                [invites setCustomText:text withSubject:@"Wow!"];
                [invites sendViaEmail:nil];
            } else if (buttonIndex == facebook_button) {
                DebugLog(@"Facebook");
            } else if (buttonIndex == twitter_button) {
                DebugLog(@"Twitter");
            }
        }
    }
}

#pragma mark - Reporting
- (void)reportUser {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You want to report this user?"
                                                    message:@"Are you sure?"
                                                   delegate:self
                                          cancelButtonTitle:@"No..."
                                          otherButtonTitles:@"Yes!", nil];
    [alert show];
}

- (void)confirmReportUser {
    [DGReport fileReportFor:self.userID ofType:@"user" inController:self.navigationController];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self confirmReportUser];
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}


#pragma mark - User listing links
- (void)showFollowers {
    [self userListWithType:@"User" typeID:user.userID andQuery:@"followers"];
}

- (void)showFollowing {
    [self userListWithType:@"User" typeID:user.userID andQuery:@"following"];
}

- (void)userListWithType:(NSString *)type typeID:(NSNumber *)typeID andQuery:(NSString *)query {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserList"];
    controller.typeID = typeID;
    controller.type = type;
    controller.query = query;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Good Listings
- (void)getUserGood {
    if (goodsButton.selected == NO) {
        [goodsButton setSelected:YES];
        [likesButton setSelected:NO];
        NSString *path = [NSString stringWithFormat:@"/goods/nominations?user_id=%@", self.userID];
        [goodTableView resetGood];
        [goodTableView loadGoodsAtPath:path];
    }
}

- (void)getUserLikes {
    if (likesButton.selected == NO) {
        [goodsButton setSelected:NO];
        [likesButton setSelected:YES];
        NSString *path = [NSString stringWithFormat:@"/goods/liked_by?user_id=%@", self.userID];
        [goodTableView resetGood];
        [goodTableView loadGoodsAtPath:path];
    }
}

@end
