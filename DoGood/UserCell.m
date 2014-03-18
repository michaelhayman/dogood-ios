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
    } else {
        UITapGestureRecognizer* userGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfile)];
        [self.username setUserInteractionEnabled:YES];
        [self.username addGestureRecognizer:userGesture];
        self.username.textColor = LINK_COLOUR;

        [self.follow addTarget:self action:@selector(followUser) forControlEvents:UIControlEventTouchUpInside];
    }

    if ([[DGUser currentUser] isSignedIn]) {
        if ([self.user.userID isEqualToNumber:[DGUser currentUser].userID]) {
            self.follow.hidden = YES;
        }
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

    [self.avatar setImageWithURL:[NSURL URLWithString:self.user.avatar_url]];

    // follows
    if ([self.user.current_user_following boolValue]) {
        [self.follow setSelected:YES];
    } else {
        [self.follow setSelected:NO];
    }
}

- (void)userProfile {
    [DGUser openProfilePage:self.user.userID inController:(UINavigationController *)self.window.rootViewController];
}

- (void)followUser {
    if (self.follow.isSelected == NO) {
        [self increaseFollow];
        [DGFollow followType:@"User" withID:self.user.userID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
            DebugLog(@"%@", msg);
        } failure:^(NSError *error) {
            [self decreaseFollow];
            DebugLog(@"failed to remove follow");
        }];
    } else {
        [self decreaseFollow];
        [DGFollow unfollowType:@"User" withID:self.user.userID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
            DebugLog(@"%@", msg);
        } failure:^(NSError *error) {
            [self increaseFollow];
            DebugLog(@"failed to remove follow");
        }];
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
