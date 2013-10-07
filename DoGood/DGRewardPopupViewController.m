#import "DGReward.h"
#import "DGRewardPopupViewController.h"
#import "UIViewController+MJPopupViewController.h"

@interface DGRewardPopupViewController ()
    @property (weak, nonatomic) IBOutlet UIImageView *teaser;
    @property (weak, nonatomic) IBOutlet UILabel *heading;
    @property (weak, nonatomic) IBOutlet UILabel *subheading;
    @property (weak, nonatomic) IBOutlet UILabel *cost;
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
}

- (IBAction)claim:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.reward, @"reward", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserClaimRewardNotification object:nil userInfo:userInfo];
}

- (IBAction)close:(id)sender {
    DebugLog(@"close it");
}

@end
