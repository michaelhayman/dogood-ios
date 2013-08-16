#import "UserCell.h"
// #import "DGGood.h"
// #import "DGVote.h"
#import "DGFollow.h"
#import <TTTAttributedLabel.h>
#import "DGUserProfileViewController.h"

@implementation UserCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // user
    self.avatar.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer* userGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfile)];
    [self.username setUserInteractionEnabled:YES];
    [self.username addGestureRecognizer:userGesture];
    self.username.textColor = LINK_COLOUR;

    // likes
    [self.follow addTarget:self action:@selector(followUser) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Set values when cell becomes visible
- (void)setValues {
    // hide the follow button for the own user
    if ([self.user.userID isEqualToNumber:[DGUser currentUser].userID]) {
        self.follow.hidden = YES;
    }
    // user
    self.username.text = self.user.full_name;
    [self.avatar setImageWithURL:[NSURL URLWithString:self.user.avatar]];
    // follows
    if ([self.user.current_user_following boolValue]) {
        [self.follow setSelected:YES];
    } else {
        [self.follow setSelected:NO];
    }
}

- (void)userProfile {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserProfileViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    controller.userID = self.user.userID;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)followUser {
    DGFollow *followUser = [DGFollow new];
    followUser.followable_id = self.user.userID;
    followUser.followable_type = @"User";

    if (self.follow.isSelected == NO) {
        [self increaseFollow];
        [[RKObjectManager sharedManager] postObject:followUser path:@"/follows" parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"failed to add follow");
            [self decreaseFollow];
        }];
    } else {
        [self decreaseFollow];
        [[RKObjectManager sharedManager] postObject:followUser path:@"/follows/remove" parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self increaseFollow];
            DebugLog(@"failed to remove regood");
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

@end
