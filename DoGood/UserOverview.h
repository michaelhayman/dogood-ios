@interface UserOverview : UIView {
    NSArray * rewards;
    __weak IBOutlet UICollectionView *rewardCollectionView;
}

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *username;
@property (nonatomic, retain) IBOutlet UILabel *points;

- (void)updatePointsText;
- (void)setContent;

@end
