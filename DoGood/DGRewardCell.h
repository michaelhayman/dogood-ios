#import <CODialog.h>
@class DGReward;

@interface DGRewardCell : UICollectionViewCell {
}

@property (weak, nonatomic) IBOutlet UILabel *heading;
@property (weak, nonatomic) IBOutlet UIImageView *teaser;
@property (weak, nonatomic) IBOutlet UILabel *subheading;
@property (weak, nonatomic) DGReward *reward;

@property (weak, nonatomic) UINavigationController *navigationController;

@property (nonatomic, strong) CODialog *dialog;

- (void)setValues;
- (void)claimReward:(id)sender;

@end
