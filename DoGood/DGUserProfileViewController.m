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
#import "DGLoadingView.h"
#import "GoodTableView.h"

@interface DGUserProfileViewController ()

@end

@implementation DGUserProfileViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    loadingView = [[DGLoadingView alloc] initCenteredOnView:tableView];

    // assume it's the current user's profile if no ID was specified
    if (self.userID == nil) {
        self.userID = [DGUser currentUser].userID;
    }

    if ([[DGUser currentUser] isSignedIn]) {
        ownProfile = [self.userID isEqualToNumber:[DGUser currentUser].userID];
    }

    if (self.fromMenu) {
        [self addMenuButton:@"MenuFromProfileIconTap" withTapButton:@"MenuFromProfileIcon"];
    }

    // conditional settings on user
    [self setupMenuTitle:@"You"];

    [self setupMoreOptions];

    // retrieve profile
    [self getProfile];

    // get good list
    goodTableView.navigationController = self.navigationController;
    goodTableView.parent = self;
    [goodTableView setupRefresh];
    [self getUserGood];

    // setup following / followers text
    UITapGestureRecognizer* followersGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowers)];
    [followers setUserInteractionEnabled:YES];
    [followers addGestureRecognizer:followersGesture];

    UITapGestureRecognizer* followingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowing)];
    [following setUserInteractionEnabled:YES];
    [following addGestureRecognizer:followingGesture];

    avatar.contentMode = UIViewContentModeScaleAspectFit;

    if (ownProfile) {
        [avatarOverlay setUserInteractionEnabled:YES];
        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(openSettings)];
        [avatarOverlay addGestureRecognizer:tap];
    } else {
        avatarOverlay.hidden = YES;
    }

    invites = [[DGUserInvitesViewController alloc] init];
    invites.parent = (UIViewController *)self;
    authenticateView.navigationController = self.navigationController;

    name.font = PROFILE_FONT;
    name.textColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:authenticateView];
    authenticateView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (![[DGUser currentUser] isSignedIn]) {
        authenticateView.hidden = NO;
        [self removeMoreOptions];
    } else {
        authenticateView.hidden = YES;
        [self setupMoreOptions];
    }
}

- (void)setDefaults {
    name.text = [DGUser currentUser].full_name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProfile) name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProfile) name:DGUserDidUpdateAccountNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProfile) name:DGUserDidUpdateFollowingsNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidUpdateAccountNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidUpdateFollowingsNotification object:nil];
}

#pragma mark - Tabs
- (void)setupTabs {
    [goodsButton addTarget:self action:@selector(getUserGood) forControlEvents:UIControlEventTouchUpInside];
    [goodsButton setTitle:[NSString stringWithFormat:@"%@ Nominations", user.posted_or_followed_goods_count] forState:UIControlStateNormal];
    [likesButton addTarget:self action:@selector(getUserLikes) forControlEvents:UIControlEventTouchUpInside];
    [likesButton setTitle:[NSString stringWithFormat:@"%@ Likes", user.liked_goods_count] forState:UIControlStateNormal];
}

#pragma mark - User retrieval
- (void)getProfile {
    [loadingView startLoading];
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

        if (!ownProfile) {
            [self setupMenuTitle:@"Profile"];
        }
        [self setupTabs];

        if (!avatar.image) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatar_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
            [avatar setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                avatar.image = image;
                if (ownProfile) {
                   avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
                    [avatar bringSubviewToFront:avatarOverlay];
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                DebugLog(@"Failed to retrieve avatar.");
            }];
        }
        [loadingView loadingSucceeded];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [loadingView loadingFailed];
        [loadingView loadingSucceeded];
    }];
}

- (void)toggleFollow {
    DGFollow *followUser = [DGFollow new];
    followUser.followable_id = user.userID;
    followUser.followable_type = @"User";

    if (centralButton.isSelected == NO) {
        [self increaseFollow];
        [[RKObjectManager sharedManager] postObject:followUser path:@"/follows" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateFollowingsNotification object:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"failed to add follow");
            [self decreaseFollow];
        }];
    } else {
        [self decreaseFollow];
        [[RKObjectManager sharedManager] deleteObject:followUser path:@"/follows/remove" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateFollowingsNotification object:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
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

- (void)setupMoreOptions {
    if (ownProfile) {
        [self setDefaults];
        UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Find Friends" style: UIBarButtonItemStylePlain target:self action:@selector(findFriends:)];
        [centralButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
        [centralButton setTitle:@"Settings" forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = connectButton;
    } else {
        // block menu options

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
