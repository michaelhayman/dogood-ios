#import "UserCell.h"
#import "DGFollow.h"
#import <TTTAttributedLabel.h>
#import "DGUserProfileViewController.h"

@implementation UserCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.avatar.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - Set values when cell becomes visible
- (void)setValues {
     if (self.disableSelection) {
        [self.username setUserInteractionEnabled:NO];
        [self.avatar setUserInteractionEnabled:NO];
         // [self.follow setUserInteractionEnabled:NO];
    } else {
        UITapGestureRecognizer* userGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfile)];
        [self.username setUserInteractionEnabled:YES];
        [self.username addGestureRecognizer:userGesture];
        self.username.textColor = LINK_COLOUR;

    }
    [self.follow addTarget:self action:@selector(followUser) forControlEvents:UIControlEventTouchUpInside];

    if ([[DGUser currentUser] isSignedIn]) {
        if ([self.user.userID isEqualToNumber:[DGUser currentUser].userID]) {
            self.follow.hidden = YES;
        } else if (self.disableSelection && ![self.user.current_user_following boolValue]) {
            self.follow.hidden = YES;
        }
    } else if (self.disableSelection && ![self.user.current_user_following boolValue]) {
        self.follow.hidden = YES;
    } else {
        self.follow.hidden = NO;
    }

    // name
    self.username.text = self.user.full_name;

    // location
    if (self.user.location) {
        self.location.text = self.user.location;
    } else {
        self.location.text = @"";
    }

    if ([self.user avatarURL]) {
        [self.avatar setImageWithURL:[self.user avatarURL]];
    } else {
        self.avatar.image = nil;
    }

    // follows
    if ([self.user.current_user_following boolValue]) {
        [self.follow setSelected:YES];
    } else {
        [self.follow setSelected:NO];
    }
}

- (void)userProfile {
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navigationController = (UINavigationController *)tabBarController.selectedViewController;

    [DGUser openProfilePage:self.user.userID inController:navigationController];
}

- (void)followUser {
    if ([[DGUser currentUser] authorizeAccess:self.navigationController.visibleViewController]) {
        if (self.follow.isSelected == NO) {
            [self increaseFollow];
            [DGFollow followType:@"User" withID:self.user.userID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidChangeFollowOnUser object:nil];
                DebugLog(@"%@", msg);
            } failure:^(NSError *error) {
                [self decreaseFollow];
                DebugLog(@"failed to remove follow");
            }];
        } else {
            [self decreaseFollow];
            [DGFollow unfollowType:@"User" withID:self.user.userID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidChangeFollowOnUser object:nil];
                DebugLog(@"%@", msg);
            } failure:^(NSError *error) {
                [self increaseFollow];
                DebugLog(@"failed to remove follow");
            }];
        }
    }
}

- (void)increaseFollow {
    [self.follow setSelected:YES];
    self.user.current_user_following = [NSNumber numberWithBool:YES];
}

- (void)decreaseFollow {
    [self.follow setSelected:NO];
    self.user.current_user_following = [NSNumber numberWithBool:NO];
}

- (void)dealloc {
}

@end
