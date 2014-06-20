#import "DGUserProfileViewController.h"
#import "DGUserGoodsTableView.h"
#import "DGUserListViewController.h"
#import "DGUserFindFriendsViewController.h"
#import "DGFollow.h"
#import "DGReport.h"
#import "DGUserInvitesViewController.h"
#import "AuthenticateView.h"
#import "UIViewController+MJPopupViewController.h"
#import <SAMLoadingView/SAMLoadingView.h>
#import <ProgressHUD/ProgressHUD.h>
#import "DGShareRankPopupViewController.h"

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

    userGoodsTableView.navigationController = self.navigationController;
    userGoodsTableView.userID = self.userID;

    invites = [[DGUserInvitesViewController alloc] init];
    invites.parent = (UIViewController *)self;

    [self initialize];

    ranking.transform = CGAffineTransformMakeRotation( - M_PI/5.5 );
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"User Profile"];
}

- (BOOL)isOwnProfile {
    return [[DGUser currentUser] isSignedIn] && [self.userID isEqualToNumber:[DGUser currentUser].userID];
}

- (void)setupOwnProfile {
    authenticateView.hidden = YES;
    DebugLog(@"from menu");
    self.userID = [DGUser currentUser].userID;
    [self setupMenuTitle:@"Your Profile"];
    [avatarOverlay setUserInteractionEnabled:YES];
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(openSettings)];
    [avatarOverlay addGestureRecognizer:tap];
    DebugLog(@"menu doesn't really help; because we have to checknot from menu");

    [self setupOwnProfileButtons];

    [self getProfile];
}

- (void)setupProfile {
    [self setupProfileButtons];

    [self getProfile];
}

- (void)setupAuth {
    [self setupMenuTitle:@"Join Do Good"];
    authenticateView.hidden = NO;
    [self removeMoreOptions];
}

- (void)initialize {
    if (self.fromMenu && ![[DGUser currentUser] isSignedIn]) {
        [self setupAuth];
        return;
    } else {
        if ([self isOwnProfile]) {
            [self setupOwnProfile];
        } else {
            [self setupProfile];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (reloadProfileOnView) {
        [self initialize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfileOnNextView) name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfileOnNextView) name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfileOnNextView) name:DGUserDidUpdateAccountNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfileOnNextView) name:DGUserDidChangeFollowOnUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfileOnNextView) name:DGUserDidPostGood object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfileOnNextView) name:DGUserDidChangeVoteOnGood object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfileOnNextView) name:DGUserDidChangeFollowOnGood object:nil];
}

- (void)deregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidUpdateAccountNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidChangeFollowOnUser object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidPostGood object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidChangeVoteOnGood object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidChangeFollowOnGood object:nil];
}

- (void)reloadProfileOnNextView {
    reloadProfileOnView = YES;
}

- (void)dealloc {
    DebugLog(@"dealloc %@", [self class]);
    [self deregisterNotifications];
}

- (void)updateFollowerStats {
    NSString *followersText = @"follower";
    followers.text = [NSString stringWithFormat:@"%@ %@", user.followers_count, [DGAppearance pluralizeString:followersText basedOnNumber:user.followers_count]];
    following.text = [NSString stringWithFormat:@"%@ following", user.following_count];
}

#pragma mark - User retrieval
- (void)getProfile {
    DebugLog(@"profile called");

    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/users/%@", self.userID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        reloadProfileOnView = NO;

        UIImage *currentAvatar = user.avatar;
        user = [[DGUser alloc] init];
        user = mappingResult.array[0];

        if ([self isOwnProfile]) {
            user.avatar = [DGUser currentUser].avatar;
        } else {
            user.avatar = currentAvatar;
        }

        name.text = user.full_name;
        [ranking setTitle:user.rank forState:UIControlStateNormal];

        [userGoodsTableView initializeTableWithUser:user];

        [self updateFollowerStats];
        if ([user.current_user_following boolValue] == YES) {
            centralButton.selected = YES;
        } else {
            centralButton.selected = NO;
        }

        if ([self isOwnProfile]) {
           avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
        } else {
           avatarOverlay.image = [UIImage imageNamed:@"ProfilePhotoFrame"];
        }
        [avatar bringSubviewToFront:avatarOverlay];

        if (user.avatar == nil) {
            [self updatePhoto];
        } else {
            avatar.image = user.avatar;
        }
        [loadingView removeFromSuperview];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [loadingView removeFromSuperview];
    }];
}

- (void)updatePhoto {
    if ([user avatarURL]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[user avatarURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
        [avatar setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                avatar.image = image;
                user.avatar = image;
            });
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            DebugLog(@"Failed to retrieve avatar.");
        }];
    } else {
        avatar.image = nil;
    }
}

- (void)childViewControllerDidUpdatePhoto:(UIImage *)image {
    avatar.image = image;
}

- (void)toggleFollow {
    if (centralButton.isSelected == NO) {
        [self increaseFollow];

        [DGFollow followType:@"User" withID:user.userID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
            DebugLog(@"%@", msg);
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidChangeFollowOnUser object:nil];
        } failure:^(NSError *error) {
            [self decreaseFollow];
            DebugLog(@"failed to remove follow");
        }];
    } else {
        [self decreaseFollow];

        [DGFollow unfollowType:@"User" withID:user.userID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidChangeFollowOnUser object:nil];
            DebugLog(@"%@", msg);
        } failure:^(NSError *error) {
            [self increaseFollow];
            DebugLog(@"failed to remove follow");
        }];
    }
}

- (void)increaseFollow {
    [centralButton setSelected:YES];
    user.followers_count = [NSNumber numberWithInt:[user.followers_count intValue] + 1];
    [self updateFollowerStats];
}

- (void)decreaseFollow {
    [centralButton setSelected:NO];
    user.followers_count = [NSNumber numberWithInt:[user.followers_count intValue] - 1];
    [self updateFollowerStats];
}

- (void)openSettings {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserSettingsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    controller.delegate = self;
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
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 addTarget:self action:@selector(findFriends:) forControlEvents:UIControlEventTouchUpInside];
    [a1 setImage:[UIImage imageNamed:@"FindFriends"] forState:UIControlStateNormal];
    [a1 sizeToFit];
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
    self.navigationItem.rightBarButtonItem = connectButton;

    [DGAppearance styleActionButton:centralButton];
    [centralButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    [centralButton setTitle:@"Settings" forState:UIControlStateNormal];
}

- (void)setupProfileButtons {
    [DGAppearance styleActionButton:centralButton];
    [centralButton setTitle:@"Follow" forState:UIControlStateNormal];
    [centralButton setTitle:@"Following" forState:UIControlStateSelected];
    [centralButton addTarget:self action:@selector(toggleFollow) forControlEvents:UIControlEventTouchUpInside];

    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 addTarget:self action:@selector(openActionMenu:) forControlEvents:UIControlEventTouchUpInside];
    [a1 setImage:[UIImage imageNamed:@"MoreProfileOptions"] forState:UIControlStateNormal];
    [a1 sizeToFit];
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
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
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Report", nil];
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

#pragma mark - Ranking
- (IBAction)openRanking:(id)sender {
    DGShareRankPopupViewController *rankingPopupController = [self.storyboard instantiateViewControllerWithIdentifier:@"shareRanking"];
    rankingPopupController.parent = self;
    rankingPopupController.user = user;
    [self.navigationController presentPopupViewController:rankingPopupController contentInteraction:MJPopupViewContentInteractionDismissBackgroundOnly];
}

@end
