#import "RootViewController.h"

@interface DGRewardsListViewController : RootViewController {
    __weak IBOutlet UISegmentedControl *tabs;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UIButton *rewardsButton;
    __weak IBOutlet UIButton *claimedButton;
    NSArray *rewards;
    IBOutlet UILabel *points;
}

@end
