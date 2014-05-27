#import "DGRewardsListViewController.h"
#import "DGRewardCell.h"
#import "DGReward.h"
#import "UIViewController+MJPopupViewController.h"

@interface DGRewardsListViewController ()

@end

@implementation DGRewardsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Rewards"];
    [collectionView registerClass:[DGRewardCell class] forCellWithReuseIdentifier:@"RewardCell"];
    UINib *nib = [UINib nibWithNibName:@"RewardCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"RewardCell"];

    [self setupTabs];
    [self showRewards];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!rewardsButton.selected && !claimedButton.selected) {
        rewardsButton.selected = YES;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVisibleRewards) name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointsText) name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePoints) name:DGUserUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClaimReward:) name:DGUserDidClaimRewardNotification object:nil];

    [self updatePointsText];
    [self updatePoints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)dealloc {
    DebugLog(@"sup");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidClaimRewardNotification object:nil];
}

#pragma mark - Update user points
- (void)updatePoints {
    [[DGUser currentUser] updatePoints];
}

- (void)updatePointsText {
    points.text = [NSString stringWithFormat:@"%@ points",  [[DGUser currentUser] pointsText]];
}

#pragma mark - Tabs
- (void)setupTabs {
    [rewardsButton addTarget:self action:@selector(showRewards) forControlEvents:UIControlEventTouchUpInside];
    [claimedButton addTarget:self action:@selector(showClaimed) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Retrieve rewards
- (void)showRewards {
    if (rewardsButton.selected == NO) {
        [self deselect:claimedButton];
        [self reselect:rewardsButton];
        NSString *path = [NSString stringWithFormat:@"/rewards"];
        [self getRewardsAtPath:path];
    }
}

- (void)deselect:(UIButton *)button {
    [DGAppearance tabButton:button on:NO withBackgroundColor:BARK andTextColor:BRILLIANCE];
}

- (void)reselect:(UIButton *)button {
    [DGAppearance tabButton:button on:YES withBackgroundColor:BRILLIANCE andTextColor:MUD];
}

- (void)showClaimed {
    if (claimedButton.selected == NO) {
        [self deselect:rewardsButton];
        [self reselect:claimedButton];
        NSString *path = [NSString stringWithFormat:@"/rewards/claimed"];
        [self getRewardsAtPath:path];
    }
}

- (void)refreshVisibleRewards {
    NSString *path;
    if (rewardsButton.selected) {
        path = [NSString stringWithFormat:@"/rewards"];
    } else {
        path = [NSString stringWithFormat:@"/rewards/claimed"];
    }
    [self getRewardsAtPath:path];
}

- (void)getRewardsAtPath:(NSString *)path {
    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        rewards = [[NSArray alloc] initWithArray:mappingResult.array];
        [collectionView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

#pragma mark - UICollectionView methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [rewards count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = @"RewardCell";
    DGRewardCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGReward *reward = rewards[indexPath.row];
    cell.reward = reward;
    if (rewardsButton.selected) {
        cell.type = @"Rewards";
    } else {
        cell.type = @"Claimed";
    }
    [cell setValues];
    cell.navigationController = self.navigationController;
    return cell;
}

#pragma mark - Change data responses
- (void)didClaimReward:(NSNotification *)notification {
    DGReward *reward = [[notification userInfo] valueForKey:@"reward"];
    [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Reward claimed!", nil) subtitle:[NSString stringWithFormat:@"%@ is yours - check the 'claimed' tab!", reward.title] type:TSMessageNotificationTypeSuccess];
}

@end
