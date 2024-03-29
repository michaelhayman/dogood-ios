#import "DGRewardsListViewController.h"
#import "DGRewardCell.h"
#import "DGReward.h"
#import "UIViewController+MJPopupViewController.h"
#import <SAMLoadingView/SAMLoadingView.h>
#import "DGRewardPopupViewController.h"

@interface DGRewardsListViewController ()

@end

#define kRewardCell @"RewardCell"

@implementation DGRewardsListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.title = @"Rewards";
        self.navigationItem.title = self.title;
        self.tabBarItem.image = [UIImage imageNamed:@"tab_rewards"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_rewards"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Rewards" withColor:[UIColor whiteColor]];

    [collectionView registerClass:[DGRewardCell class] forCellWithReuseIdentifier:kRewardCell];
    UINib *nib = [UINib nibWithNibName:kRewardCell bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:kRewardCell];

    loadingView = [[SAMLoadingView alloc] initWithFrame:collectionView.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [collectionView addSubview:loadingView];

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
    [self customizeNavColor:CRIMSON];
    if (!rewardsButton.selected && !claimedButton.selected) {
        rewardsButton.selected = YES;
        [self deselect:claimedButton];
        [self reselect:rewardsButton];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointsText) name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePoints) name:DGUserUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClaimReward:) name:DGUserDidClaimRewardNotification object:nil];

    [self updatePointsText];
    [self updatePoints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"Reward List"];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidClaimRewardNotification object:nil];
}

#pragma mark - Update user points
- (void)updatePoints {
    if ([[DGUser currentUser] isSignedIn]) {
        [[DGUser currentUser] updatePoints];
    } else {
        if ([rewards count] == 0) {
            [self loadRewards];
        }
    }
}

- (void)updatePointsText {
    if ([[DGUser currentUser] isSignedIn]) {
        NSString *newPointsText = [NSString stringWithFormat:@"%@ %@",  [[DGUser currentUser] pointsText], [DGAppearance pluralizeString:@"point" basedOnNumber:[DGUser currentUser].points]];
        if (![points.text isEqualToString:newPointsText]) {
            points.text = [NSString stringWithFormat:@"%@ %@",  [[DGUser currentUser] pointsText], [DGAppearance pluralizeString:@"point" basedOnNumber:[DGUser currentUser].points]];
            [self refreshVisibleRewards];
        }
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
    if ([rewards count] > 0) {
        return [rewards count];
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([rewards count] > 0) {
        static NSString *reuseIdentifier = kRewardCell;
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
        cell.interactionEnabled = YES;
        return cell;
    } else {
        static NSString *reuseIdentifier = kRewardCell;
        DGRewardCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGReward *reward = [[DGReward alloc] initWithEmptyReward];
        cell.reward = reward;
        [cell setValues];
        cell.interactionEnabled = NO;
        return cell;
    }
}

#pragma mark - Change data responses
- (void)didClaimReward:(NSNotification *)notification {
    DGReward *reward = [[notification userInfo] valueForKey:@"reward"];

    DGRewardPopupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"rewardInstructionsPopup"];
    controller.reward = reward;
    controller.claimed = YES;
    [self.navigationController presentPopupViewController:controller animationType:MJPopupViewAnimationSlideBottomBottom contentInteraction:MJPopupViewContentInteractionDismissBackgroundOnly];
}

@end
