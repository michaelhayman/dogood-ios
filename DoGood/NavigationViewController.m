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

    REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:@"Explore" subtitle:nil image:[UIImage imageNamed:@"MenuIconExplore"] highlightedImage:[UIImage imageNamed:@"MenuIconExploreTap"] action:^(REMenuItem *item) {
        NSLog(@"Item: %@", item);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Explore" bundle:nil];
        DGExploreViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"explore"];
        [weakSelf setViewControllers:@[controller] animated:NO];
    }];

    REMenuItem *rewardsItem = [[REMenuItem alloc] initWithTitle:@"Rewards" subtitle:nil image:[UIImage imageNamed:@"MenuIconRewards"] highlightedImage:[UIImage imageNamed:@"MenuIconRewardsTap"] action:^(REMenuItem *item) { NSLog(@"Item: %@", item);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Rewards" bundle:nil];
        DGRewardsListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"rewardList"];
        [weakSelf setViewControllers:@[controller] animated:NO];

    }];

    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"MenuIconProfile"] highlightedImage:[UIImage imageNamed:@"MenuIconProfileTap"] action:^(REMenuItem *item) {
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
    _menu.shadowRadius = 1;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 0);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(7, -1);
    //_menu.textAlignment = NSTextAlignmentLeft;
    //_menu.textOffset = CGSizeMake(80, 0);

    _menu.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    _menu.textShadowOffset = CGSizeMake(0, 0);
    _menu.textShadowColor = [UIColor clearColor];
    _menu.highlightedTextShadowColor = _menu.textShadowColor;
    _menu.separatorColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
    _menu.borderColor = _menu.backgroundColor;

    _menu.highlightedBackgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    _menu.highlightedSeparatorColor = _menu.highlightedBackgroundColor;
    _menu.highlightedTextShadowOffset = CGSizeMake(0, 0);
    _menu.highlightedTextColor = MENU_FONT_COLOR;
    _menu.font = MENU_FONT;
    // _menu.backgroundColor = [UIColor clearColor];
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
