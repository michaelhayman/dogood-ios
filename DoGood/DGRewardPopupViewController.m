#import "DGReward.h"
#import "DGRewardPopupViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "UIImage+Grayscale.h"

@interface DGRewardPopupViewController ()
    @property (weak, nonatomic) IBOutlet UIImageView *teaser;
    @property (weak, nonatomic) IBOutlet UILabel *heading;
    @property (weak, nonatomic) IBOutlet UILabel *subheading;
    @property (weak, nonatomic) IBOutlet UILabel *cost;
    @property (weak, nonatomic) IBOutlet UITextView *instructions;
@end

@implementation DGRewardPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setStyle];
    [self setContents];
}

- (void)setStyle {
    self.teaser.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)setContents {
    [self.teaser setImageWithURL:[NSURL URLWithString:self.reward.teaser]];
    self.heading.text = self.reward.title;
    self.subheading.text = self.reward.subtitle;
    self.cost.text = [self.reward costText];

    if (![self hasSufficientPoints]) {
        self.instructions.text = @"You don't have enough points to buy this item!";
        self.teaser.image = [self.teaser.image convertToGrayscale];
    } else {
        self.instructions.text = self.reward.instructions;
    }
}

- (bool)hasSufficientPoints {
    return [[DGUser currentUser].points intValue] >= [self.reward.cost intValue];
}

- (IBAction)claim:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You want this?" message:@"Are you sure?" delegate:self cancelButtonTitle:@"No..." otherButtonTitles:@"Yes!", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self confirmClaim];
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

- (void)confirmClaim {
    [self claimReward];
    [self close:nil];
}

- (void)claimReward {
    [[RKObjectManager sharedManager] postObject:self.reward path:@"/rewards/claim" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.reward, @"reward", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserUpdatePointsNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidClaimRewardNotification object:nil userInfo:userInfo];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Reward not claimed.", nil) subtitle:[error localizedDescription] type:TSMessageNotificationTypeError];
    }];
}

- (IBAction)close:(id)sender {
    [self dismissPopupViewController:self animationType:MJPopupViewAnimationSlideBottomBottom];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
