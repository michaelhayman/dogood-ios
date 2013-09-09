#import "NavigationViewController.h"
#import "DGUserProfileViewController.h"
#import "DGGoodListViewController.h"
#import "DGExploreViewController.h"
#import "DGRewardsListViewController.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

- (void)showGoodList {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    __typeof (&*self) __weak weakSelf = self;
    [weakSelf setViewControllers:@[controller] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.tintColor = [UIColor blueColor];
    self.navigationBar.tintColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleMenu) name:DGUserDidToggleMenu object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showGoodList)
                                                 name:DGUserDidSignOutNotification
                                               object:nil];

    __typeof (&*self) __weak weakSelf = self;

    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Do Good" subtitle:nil image:[UIImage imageNamed:@"MenuIconHome"] highlightedImage:[UIImage imageNamed:@"MenuIconHomeTap"] action:^(REMenuItem *item) {
        NSLog(@"Item: %@", item);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
        DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
        [weakSelf setViewControllers:@[controller] animated:NO];
    }];

    REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:@"Explore" subtitle:nil image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {
        NSLog(@"Item: %@", item);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Explore" bundle:nil];
        DGExploreViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"explore"];
        [weakSelf setViewControllers:@[controller] animated:NO];
    }];

    REMenuItem *rewardsItem = [[REMenuItem alloc] initWithTitle:@"Rewards" subtitle:nil image:[UIImage imageNamed:@"Icon_Activity"] highlightedImage:nil action:^(REMenuItem *item) { NSLog(@"Item: %@", item);

        DGRewardsListViewController *controller = [[DGRewardsListViewController alloc] initWithNibName:@"DGRewardsListViewController" bundle:nil];
        [weakSelf setViewControllers:@[controller] animated:NO];

    }];

    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"Icon_Profile"] highlightedImage:nil action:^(REMenuItem *item) {
        NSLog(@"Item: %@", item);
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
         DGUserProfileViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
         controller.fromMenu = YES;
         [weakSelf setViewControllers:@[controller] animated:NO];
    }];

    homeItem.tag = 0;
    exploreItem.tag = 1;
    rewardsItem.tag = 3;
    profileItem.tag = 4;
    
    _menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, rewardsItem, profileItem]];
    _menu.cornerRadius = 4;
    _menu.shadowRadius = 4;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 1);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(5, -1);
    _menu.waitUntilAnimationIsComplete = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    DebugLog(@"dispapeared nv");
    if (_menu && _menu.isOpen) {
        [_menu close];
    }
    DebugLog(@"not the cause");
}

- (void)toggleMenu {
    if (_menu.isOpen)
        return [_menu close];
    
    [_menu showFromNavigationController:self];
}

@end
