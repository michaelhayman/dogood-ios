#import "DGRewardsListViewController.h"
#import "DGRewardCell.h"
#import "DGReward.h"

@interface DGRewardsListViewController ()

@end

@implementation DGRewardsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [collectionView registerClass:[DGRewardCell class] forCellWithReuseIdentifier:@"RewardCell"];
    UINib *nib = [UINib nibWithNibName:@"Reward" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"RewardCell"];
    collectionView.backgroundColor = [UIColor whiteColor];



    [self setupTabs];

    [self addMenuButton:@"MenuFromHomeIcon" withTapButton:@"MenuFromHomeIconTap"];
}

- (void)viewWillAppear:(BOOL)animated {
    // move this into a notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRewards) name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePoints) name:DGUserUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(claimReward:) name:DGUserClaimRewardNotification object:nil];
    [self updatePoints];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Update user points
- (void)updatePoints {
    [[DGUser currentUser] updatePoints];
}

#pragma mark - Tabs
- (void)setupTabs {
    [rewardsButton addTarget:self action:@selector(showRewards) forControlEvents:UIControlEventTouchUpInside];
    // [rewardsButton setTitle:[NSString stringWithFormat:@"%@ GOODS", user.posted_or_followed_goods_count] forState:UIControlStateNormal];
    [claimedButton addTarget:self action:@selector(showClaimed) forControlEvents:UIControlEventTouchUpInside];
    // [claimedButton setTitle:[NSString stringWithFormat:@"%@ LIKES", user.liked_goods_count] forState:UIControlStateNormal];
}

#pragma mark - Retrieve rewards
- (void)showRewards {
    if (rewardsButton.selected == NO) {
        [rewardsButton setSelected:YES];
        [claimedButton setSelected:NO];
        NSString *path = [NSString stringWithFormat:@"/rewards"];
        [self getRewardsAtPath:path];
    }
}

- (void)showClaimed {
    if (claimedButton.selected == NO) {
        [rewardsButton setSelected:NO];
        [claimedButton setSelected:YES];
        NSString *path = [NSString stringWithFormat:@"/rewards/claimed"];
        [self getRewardsAtPath:path];
    }
}

- (void)getRewardsAtPath:(NSString *)path {
    points.text = [NSString stringWithFormat:@"%@ points", [DGUser currentUser].points];
    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        rewards = [[NSArray alloc] initWithArray:mappingResult.array];
        [collectionView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

#pragma mark - UICollectionView methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DebugLog(@"rewards %@, %d", rewards, [rewards count]);
    return [rewards count];
    // return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = @"RewardCell";
    DGRewardCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGReward *reward = rewards[indexPath.row];
    cell.reward = reward;
    [cell setValues];
    cell.navigationController = self.navigationController;
    // cell.picture.image = [UIImage imageNamed:@"upload-image"];

    return cell;
}

#pragma mark - Change data responses
- (void)claimReward:(NSNotification *)notification {
    DGReward *reward = [[notification userInfo] valueForKey:@"reward"];

    [[RKObjectManager sharedManager] postObject:reward path:@"/rewards/claim" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [TSMessage showNotificationInViewController:self withTitle:NSLocalizedString(@"Claimed reward!", nil) withMessage:[NSString stringWithFormat:@"%@ is yours", reward.title] withType:TSMessageNotificationTypeSuccess];
        DebugLog(@"set claimed rewards tab");
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserUpdatePointsNotification object:nil];
        [claimedButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        // [collectionView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [TSMessage showNotificationInViewController:self withTitle:NSLocalizedString(@"Reward not claimed.", nil) withMessage:[error localizedDescription] withType:TSMessageNotificationTypeError];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSendPasswordNotification object:nil];
    }];
}

@end
