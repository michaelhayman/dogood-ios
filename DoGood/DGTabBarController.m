#import "DGTabBarController.h"
#import "DGRewardsListViewController.h"
#import "DGUserProfileViewController.h"
#import "DGToDoListViewController.h"
#import "DGExploreViewController.h"

@interface DGTabBarController () <UITabBarControllerDelegate>

@end

@implementation DGTabBarController

- (id)init {
    self = [super init];
    if (self) {
        [self setUpTabController];
        self.delegate = self;
    }
    return self;
}

#pragma mark - Further view initialization
- (UITabBarController *)setUpTabController {
    NSMutableArray *localControllersArray = [[NSMutableArray alloc] initWithCapacity:4];

    [[self tabBar] setSelectedImageTintColor:VIVID];
    [[self tabBar] setTintColor:VIVID];

    UIStoryboard *explore = [UIStoryboard storyboardWithName:@"Explore" bundle:nil];
    DGExploreViewController *exploreController = [explore instantiateViewControllerWithIdentifier:@"explore"];
    [self addController:exploreController toArray:localControllersArray];

    UIStoryboard *goodStoryboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGToDoListViewController *todoController = [goodStoryboard instantiateViewControllerWithIdentifier:@"DGToDoListViewController"];
    [self addController:todoController toArray:localControllersArray];

    UIStoryboard *rewards = [UIStoryboard storyboardWithName:@"Rewards" bundle:nil];
    DGRewardsListViewController *rewardsController = [rewards instantiateViewControllerWithIdentifier:@"rewardList"];
    [self addController:rewardsController toArray:localControllersArray];

    UIStoryboard *usersStoryboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserProfileViewController *profileController = [usersStoryboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    [self addController:profileController toArray:localControllersArray];

    self.viewControllers = localControllersArray;
    return self;
}

- (void)addController:(UIViewController *)controller toArray:(NSMutableArray *)array {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [array addObject:nav];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        DGUserProfileViewController *controller = [nav.viewControllers firstObject];
        if ([controller isKindOfClass:[DGUserProfileViewController class]]) {
            controller.userID = [DGUser currentUser].userID;
            controller.fromMenu = YES;
        }
    }
}

@end
