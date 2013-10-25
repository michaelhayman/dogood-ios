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
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.reward, @"reward", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserClaimRewardNotification object:nil userInfo:userInfo];
    [self close:nil];
}

- (IBAction)close:(id)sender {
    [self dismissPopupViewController:self animationType:MJPopupViewAnimationSlideBottomBottom];
}

@end
