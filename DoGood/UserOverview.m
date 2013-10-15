#import "UserOverview.h"
#import "constants.h"
#import "DGReward.h"
// #import "DGRewardMiniCell.h"
#import "DGRewardCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UserOverview

#pragma mark - Initialization & reuse
- (id)initWithFrame:(CGRect)frame {
    frame = CGRectMake(0, 0, 320, 106);
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"UserOverview" owner:self options:nil];
        [self addSubview:self.view];

        [self setContent];
        [self style];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addSubview:self.view];
    [self setupNotifications];
}

- (void)setContent {
    self.username.text = [DGUser currentUser].username;
    [self updatePointsText];
    [self setupRewardCell];
    [self getRewardsAtPath:@"/rewards/highlights"];
}

- (void)style {
    // self.points.textColor = [UIColor whiteColor];
    // self.username.textColor = [UIColor whiteColor];
    // self.view.backgroundColor = COLOUR_REDDISH_BROWN;
    // rewardCollectionView.layer
    [rewardCollectionView.layer setBorderWidth:1.0];
    rewardCollectionView.layer.cornerRadius = 5;
    rewardCollectionView.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointsText) name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointsText) name:DGUserDidPostGood object:nil];
}

#pragma mark - Content methods
- (void)updatePointsText {
    self.points.text = [NSString stringWithFormat:@"%@ points", [[DGUser currentUser] pointsText]];
}

#pragma mark - UICollectionView methods
- (void)setupRewardCell {
   [rewardCollectionView registerClass:[DGRewardCell class] forCellWithReuseIdentifier:@"RewardCell"];
    UINib *nib = [UINib nibWithNibName:@"DGRewardMiniCell" bundle:nil];
    [rewardCollectionView registerNib:nib forCellWithReuseIdentifier:@"RewardCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [rewards count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = @"RewardCell";
    DGRewardCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGReward *reward = rewards[indexPath.row];
    cell.reward = reward;
    [cell setValues];
    return cell;
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DGReward *reward = rewards[indexPath.row];
    DebugLog(@"reward %@", reward);
}

- (void)getRewardsAtPath:(NSString *)path {
    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        rewards = [[NSArray alloc] initWithArray:mappingResult.array];
        [rewardCollectionView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

@end