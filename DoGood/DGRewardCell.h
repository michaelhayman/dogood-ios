@class DGReward;

@interface DGRewardCell : UICollectionViewCell {
}

@property (weak, nonatomic) DGReward *reward;
@property (weak, nonatomic) IBOutlet UILabel *heading;
@property (weak, nonatomic) IBOutlet UIImageView *teaser;
@property (weak, nonatomic) IBOutlet UILabel *subheading;
@property (weak, nonatomic) IBOutlet UILabel *cost;

@property (weak, nonatomic) NSString *type;
@property (weak, nonatomic) UINavigationController *navigationController;
@property BOOL interactionEnabled;

- (void)setValues;
- (void)options;

@end
