#import "REMenu.h"
@class DGUserProfileViewController;
@class DGExploreViewController;
@class DGGoodListViewController;
@class DGRewardListViewController;
#import <CRNavigationController/CRNavigationController.h>

@interface NavigationViewController : CRNavigationController {
    DGGoodListViewController *goodListController;
    DGRewardListViewController *rewardListController;
    DGUserProfileViewController *userProfileController;
    DGExploreViewController *exploreController;
}

@property (strong, readonly, nonatomic) REMenu *menu;

- (void)toggleMenu;

@end
