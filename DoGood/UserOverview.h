@interface UserOverview : UIView {
    NSArray * rewards;
    __weak IBOutlet UICollectionView *rewardCollectionView;
}

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UIImageView *image;
@property (nonatomic, strong) IBOutlet UILabel *username;
@property (nonatomic, strong) IBOutlet UILabel *points;

@property (weak, nonatomic) UINavigationController *navigationController;

- (id)initWithController:(UINavigationController *)controller;
- (void)updatePointsText;
- (void)setContent;

@end
