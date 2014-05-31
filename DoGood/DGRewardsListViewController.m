#import "DGRewardsListViewController.h"
#import "DGRewardCell.h"
#import "DGReward.h"
#import "UIViewController+MJPopupViewController.h"
#import <SAMLoadingView/SAMLoadingView.h>

@interface DGRewardsListViewController ()

@end

@implementation DGRewardsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Rewards"];

    [collectionView registerClass:[DGRewardCell class] forCellWithReuseIdentifier:@"RewardCell"];
    UINib *nib = [UINib nibWithNibName:@"RewardCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"RewardCell"];

    loadingView = [[SAMLoadingView alloc] initWithFrame:collectionView.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self setupTabs];

    UITapGestureRecognizer* openPointsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(authorizeUser)];
    [points setUserInteractionEnabled:YES];
    [points addGestureRecognizer:openPointsGesture];

    [self setupRefresh];
}

- (void)authorizeUser {
    [[DGUser currentUser] authorizeAccess:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    if ([[DGUser currentUser] isSignedIn]) {
        [[DGUser currentUser] updatePoints];
    }
}

- (void)updatePointsText {
    if ([[DGUser currentUser] isSignedIn]) {
        points.text = [NSString stringWithFormat:@"%@ points",  [[DGUser currentUser] pointsText]];
    } else {
        points.text = @"Join and earn points!";
    }
}

#pragma mark - Tabs
- (void)setupTabs {
    [rewardsButton addTarget:self action:@selector(showRewards) forControlEvents:UIControlEventTouchUpInside];
    [claimedButton addTarget:self action:@selector(showClaimed) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Retrieve rewards
- (void)setupRefresh {
    collectionView.alwaysBounceVertical = YES;
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = VIVID;
    [refreshControl addTarget:self action:@selector(refreshVisibleRewards)
             forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
}

- (void)showRewards {
    if (rewardsButton.selected == NO) {
        [self loadRewards];
    }
}

- (void)loadRewards {
    [self deselect:claimedButton];
    [self reselect:rewardsButton];
    NSString *path = [NSString stringWithFormat:@"/rewards"];
    [self getRewardsAtPath:path];
}

- (void)deselect:(UIButton *)button {
    [DGAppearance tabButton:button on:NO withBackgroundColor:BARK andTextColor:BRILLIANCE];
}

- (void)reselect:(UIButton *)button {
    [DGAppearance tabButton:button on:YES withBackgroundColor:BRILLIANCE andTextColor:MUD];
}

- (void)showClaimed {
    if ([[DGUser currentUser] authorizeAccess:self]) {
        if (claimedButton.selected == NO) {
            [self loadClaimed];
        }
    }
}

- (void)loadClaimed {
    [self deselect:rewardsButton];
    [self reselect:claimedButton];
    NSString *path = [NSString stringWithFormat:@"/rewards/claimed"];
    [self getRewardsAtPath:path];
}

- (void)refreshVisibleRewards {
    if (rewardsButton.selected) {
        [self loadRewards];
    } else {
        [self loadClaimed];
    }
}

- (void)getRewardsAtPath:(NSString *)path {
    [refreshControl endRefreshing];
    [collectionView addSubview:loadingView];
    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        rewards = [[NSArray alloc] initWithArray:mappingResult.array];
        [collectionView reloadData];
        [loadingView removeFromSuperview];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [loadingView removeFromSuperview];
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
    [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Reward claimed!", nil) subtitle:[NSString stringWithFormat:@"%@ is yours - check the 'claimed rewards' tab!", reward.title] type:TSMessageNotificationTypeSuccess];
}

@end
