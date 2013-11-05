#import "REMenu.h"
@class DGUserProfileViewController;
@class DGExploreViewController;
@class DGGoodListViewController;
@class DGRewardListViewController;

@interface NavigationViewController : UINavigationController {
    DGGoodListViewController *goodListController;
    DGRewardListViewController *rewardListController;
    DGUserProfileViewController *userProfileController;
    DGExploreViewController *exploreController;
}

@property (strong, readonly, nonatomic) REMenu *menu;

- (void)toggleMenu;

@end
