@class SAMLoadingView;

@interface DGRewardsListViewController : DGViewController {
    __weak IBOutlet UISegmentedControl *tabs;
    __weak IBOutlet UICollectionView *collectionView;
    UIRefreshControl *refreshControl;
    __weak IBOutlet UIButton *rewardsButton;
    __weak IBOutlet UIButton *claimedButton;
    NSArray *rewards;
    IBOutlet UILabel *points;
    SAMLoadingView *loadingView;
}

@end
