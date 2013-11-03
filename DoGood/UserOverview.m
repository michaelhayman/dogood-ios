#import "UserOverview.h"
#import "constants.h"
#import "DGReward.h"
// #import "DGRewardMiniCell.h"
#import "DGRewardCell.h"
#import "UIViewController+MJPopupViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation UserOverview

#pragma mark - Initialization & reuse
- (id)initWithController:(UINavigationController *)controller {
    CGRect frame = CGRectMake(0, 0, 320, 90);
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"UserOverview" owner:self options:nil];
        [self addSubview:self.view];
        self.navigationController = controller;

        [self setContent];
        [self style];
        [self setupNotifications];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addSubview:self.view];
}

- (void)setContent {
    self.username.text = [DGUser currentUser].full_name;
    [self updatePointsText];
    [self setupRewardCell];
    [self getRewardsAtPath:@"/rewards/highlights"];
}

- (void)style {
    // self.points.textColor = [UIColor whiteColor];
    // self.username.textColor = [UIColor whiteColor];
    // self.view.backgroundColor = COLOUR_REDDISH_BROWN;
    // rewardCollectionView.layer
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointsText) name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointsText) name:DGUserDidPostGood object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClaimReward:) name:DGUserDidClaimRewardNotification object:nil];
}

- (void)dealloc {
    DebugLog(@"deallocing user overview!");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidPostGood object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidClaimRewardNotification object:nil];
}

#pragma mark - Content methods
- (void)updatePointsText {
    self.points.text = [NSString stringWithFormat:@"%@ points", [[DGUser currentUser] pointsText]];
}

#pragma mark - UICollectionView methods
- (void)setupRewardCell {
    [rewardCollectionView registerClass:[DGRewardCell class] forCellWithReuseIdentifier:@"RewardCell"];
    UINib *nib = [UINib nibWithNibName:@"RewardMiniCell" bundle:nil];
    [rewardCollectionView registerNib:nib forCellWithReuseIdentifier:@"RewardCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [rewards count];
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *reuseIdentifier = @"RewardCell";
        DGRewardCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGReward *reward = rewards[indexPath.row];
        cell.reward = reward;
        cell.contentView.layer.borderWidth = 1.0;
        cell.contentView.layer.cornerRadius = 10;
        cell.contentView.layer.borderColor = [[UIColor grayColor] CGColor];
        [cell setValues];
        cell.navigationController = self.navigationController;
        cell.type = @"Rewards";
        return cell;
    } else {
        static NSString *reuseIdentifier = @"RewardCell";
        DGRewardCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGReward *reward = [DGReward new];
        cell.reward = reward;
        reward.title = @"And\nmore";
        [cell setValues];
        cell.cost.text = @"See all";
        cell.teaser.image = [UIImage imageNamed:@"MenuIconRewards"];
        cell.contentView.layer.borderWidth = 1.0;
        cell.contentView.layer.cornerRadius = 10;
        cell.contentView.layer.borderColor = [[UIColor grayColor] CGColor];
        cell.navigationController = self.navigationController;
        cell.type = @"See all";
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DGRewardCell *cell = (DGRewardCell *)[aCollectionView cellForItemAtIndexPath:indexPath];
    [cell options];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 2;
}

- (void)getRewardsAtPath:(NSString *)path {
    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        rewards = [[NSArray alloc] initWithArray:mappingResult.array];
        [rewardCollectionView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

- (void)didClaimReward:(NSNotification *)notification {
    DGReward *reward = [[notification userInfo] valueForKey:@"reward"];
    [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Reward claimed!", nil) subtitle:[NSString stringWithFormat:@"%@ is yours", reward.title] type:TSMessageNotificationTypeSuccess];
}

@end