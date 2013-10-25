#import "DGRewardCell.h"
#import "DGReward.h"
#import "DGRewardPopupViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "UIImage+Grayscale.h"

@implementation DGRewardCell

- (void)awakeFromNib {
    self.heading.preferredMaxLayoutWidth=100.0;
    self.subheading.preferredMaxLayoutWidth=100.0;

    // gestures
    UITapGestureRecognizer* headingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(options)];
    [self.heading setUserInteractionEnabled:YES];
    [self.heading addGestureRecognizer:headingGesture];

    UITapGestureRecognizer* subHeadingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(options)];
    [self.subheading setUserInteractionEnabled:YES];
    [self.subheading addGestureRecognizer:subHeadingGesture];

    UITapGestureRecognizer* costGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(options)];
    [self.cost setUserInteractionEnabled:YES];
    [self.cost addGestureRecognizer:costGesture];

    UITapGestureRecognizer* teaserGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(options)];
    [self.teaser setUserInteractionEnabled:YES];
    [self.teaser addGestureRecognizer:teaserGesture];

    self.teaser.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setValues {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.reward.teaser] cachePolicy:NSURLRequestUseProtocolCachePolicy                                  timeoutInterval:15.0];
    [self.teaser setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (![self hasSufficientPoints] && [self.type isEqualToString:@"Rewards"]) {
            self.teaser.image = [image convertToGrayscale];
        } else {
            self.teaser.image = image;
        }
    } failure:nil];

    if (![self hasSufficientPoints] && [self.type isEqualToString:@"Rewards"]) {
        self.heading.textColor = GRAYED_OUT;
        self.subheading.textColor = GRAYED_OUT;
        self.cost.textColor = GRAYED_OUT;
    } else {
        self.heading.textColor = ACTIVE;
        self.subheading.textColor = ACTIVE;
        self.cost.textColor = ACTIVE;
    }

    self.heading.text = self.reward.title;
    self.subheading.text = self.reward.subtitle;
    self.cost.text = [self.reward costText];
}

- (bool)hasSufficientPoints {
    return [[DGUser currentUser].points intValue] >= [self.reward.cost intValue];
}

#pragma mark - Options
- (void)options {
    if ([self.type isEqualToString:@"Rewards"]) {
        if (![self hasSufficientPoints]) {
            [self displayInsufficientPoints];
        } else {
            [self claim];
        }
    } else if ([self.type isEqualToString:@"See all"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSelectRewards object:nil];
    } else {
        [self instructions];
    }
}

- (void)displayInsufficientPoints {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Rewards" bundle:nil];
    DGRewardPopupViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"rewardInsufficientPointsPopup"];
    controller.reward = self.reward;
    [self.navigationController presentPopupViewController:controller contentInteraction:MJPopupViewContentInteractionDismissBackgroundOnly];
}

#pragma mark - Instructions dialog
- (void)claim {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Rewards" bundle:nil];
    DGRewardPopupViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"rewardClaimPopup"];
    controller.reward = self.reward;
    [self.navigationController presentPopupViewController:controller animationType:MJPopupViewAnimationSlideBottomBottom contentInteraction:MJPopupViewContentInteractionDismissBackgroundOnly];
}

- (void)instructions {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Rewards" bundle:nil];
    DGRewardPopupViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"rewardInstructionsPopup"];
    controller.reward = self.reward;
    [self.navigationController presentPopupViewController:controller animationType:MJPopupViewAnimationSlideBottomBottom contentInteraction:MJPopupViewContentInteractionDismissBackgroundOnly];
}

@end
