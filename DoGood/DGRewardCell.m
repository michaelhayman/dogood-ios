#import "DGRewardCell.h"
#import "DGReward.h"
#import <CODialog.h>

@implementation DGRewardCell

- (void)awakeFromNib {
    self.heading.preferredMaxLayoutWidth=100.0;
    self.subheading.preferredMaxLayoutWidth=100.0;

    // gestures
    UITapGestureRecognizer* headingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(claim)];
    [self.heading setUserInteractionEnabled:YES];
    [self.heading addGestureRecognizer:headingGesture];

    UITapGestureRecognizer* subHeadingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(claim)];
    [self.subheading setUserInteractionEnabled:YES];
    [self.subheading addGestureRecognizer:subHeadingGesture];

    UITapGestureRecognizer* teaserGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(claim)];
    [self.teaser setUserInteractionEnabled:YES];
    [self.teaser addGestureRecognizer:teaserGesture];

    self.teaser.contentMode = UIViewContentModeScaleAspectFit;

    self.dialog = [CODialog dialogWithWindow:[[[UIApplication sharedApplication] delegate] window]];
}

- (void)setValues {
    [self.teaser setImageWithURL:[NSURL URLWithString:self.reward.teaser]];
    self.heading.text = self.reward.title;
    self.subheading.text = self.reward.subtitle;
}

#pragma mark - Claim dialog
- (void)claim {
    NSLog(@"custom");
    [self.dialog resetLayout];

    UIImageView *view = [[UIImageView alloc] init];
    [view setImageWithURL:[NSURL URLWithString:self.reward.teaser]];
    view.frame = CGRectMake(0, 0, 128, 128);
    view.contentMode = UIViewContentModeScaleAspectFit;

    self.dialog.title = self.heading.text;
    self.dialog.subtitle = [NSString stringWithFormat:@"%@\n%@", self.subheading.text, self.reward.cost];
    self.dialog.dialogStyle = CODialogStyleCustomView;
    // self.dialog.customView = view;
    self.dialog.customView = view;

    [self.dialog addButtonWithTitle:@"Nah" target:self selector:@selector(hideAndShow:)];
    [self.dialog addButtonWithTitle:@"Yes!" target:self selector:@selector(claimReward:) highlighted:YES];
    [self.dialog showOrUpdateAnimated:YES];
}

- (void)hideAndShow:(id)sender {
    [self.dialog hideAnimated:YES];
}

#pragma mark - Claim reward
- (void)claimReward:(id)sender {
    [self.dialog hideAnimated:YES];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.reward, @"reward", nil];
    DebugLog(@"reward %@ %@", self.reward, userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserClaimRewardNotification object:nil userInfo:userInfo];
}

@end
