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
    if (goodListController == nil) {
        goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    }
    __typeof (&*self) __weak weakSelf = self;
    [weakSelf setViewControllers:@[goodListController] animated:NO];
}

- (void)showRewards {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Rewards" bundle:nil];
    if (rewardListController == nil) {
        rewardListController = [storyboard instantiateViewControllerWithIdentifier:@"rewardList"];
    }
    __typeof (&*self) __weak weakSelf = self;
    [weakSelf setViewControllers:@[rewardListController] animated:NO];
}

- (void)showExplore {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Explore" bundle:nil];
    if (exploreController == nil) {
        exploreController = [storyboard instantiateViewControllerWithIdentifier:@"explore"];
    }
    __typeof (&*self) __weak weakSelf = self;
    [weakSelf setViewControllers:@[exploreController] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DebugLog(@"did appear");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleMenu) name:DGUserDidToggleMenu object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRewards) name:DGUserDidSelectRewards object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showExplore) name:DGUserDidSignOutNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    __typeof (&*self) __weak weakSelf = self;

    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Done" subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item) {
        NSLog(@"Item: %@", item);
        [self showGoodList];
    }];

    REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:@"To Do" subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item) {
        NSLog(@"Item: %@", item);
        [self showExplore];
    }];

    REMenuItem *rewardsItem;
    if (REWARDS_ENABLED) {
        rewardsItem = [[REMenuItem alloc] initWithTitle:@"Rewards" subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item) {
            NSLog(@"Item: %@", item);
            [self showRewards];
        }];
    }

    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:@"My Profile" image:nil highlightedImage:nil action:^(REMenuItem *item) {
        NSLog(@"Item: %@", item);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
        if (userProfileController == nil) {
            userProfileController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
        }
        userProfileController.fromMenu = YES;
        userProfileController.userID = [DGUser currentUser].userID;
        [weakSelf setViewControllers:@[userProfileController] animated:NO];
    }];

    homeItem.tag = 0;
    exploreItem.tag = 1;
    rewardsItem.tag = 3;
    profileItem.tag = 4;

    if (REWARDS_ENABLED) {
        _menu = [[REMenu alloc] initWithItems:@[exploreItem, homeItem, rewardsItem, profileItem]];
    } else {
        _menu = [[REMenu alloc] initWithItems:@[exploreItem, homeItem, profileItem]];
    }

    _menu.cornerRadius = 4;
    _menu.shadowRadius = 1;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 0);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(7, -1);
    //_menu.textAlignment = NSTextAlignmentLeft;
    //_menu.textOffset = CGSizeMake(80, 0);

    _menu.backgroundColor = MUD_TRANSPARENT;
    _menu.textShadowOffset = CGSizeMake(0, 0);
    _menu.textShadowColor = [UIColor clearColor];
    _menu.highlightedTextShadowColor = _menu.textShadowColor;
    _menu.separatorColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
    _menu.borderColor = _menu.backgroundColor;

    _menu.highlightedBackgroundColor = [UIColor blackColor];
    _menu.highlightedSeparatorColor = _menu.highlightedBackgroundColor;
    _menu.highlightedTextShadowOffset = CGSizeMake(0, 0);
    _menu.highlightedTextColor = [UIColor whiteColor];
    _menu.font = MENU_FONT;
    _menu.textColor = [UIColor whiteColor];
    _menu.itemHeight = 75;
    _menu.liveBlur = YES;
    _menu.liveBlurTintColor = MUD;
    // _menu.backgroundColor = [UIColor clearColor];
    _menu.waitUntilAnimationIsComplete = NO;
}

// - (void)dealloc {
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    DebugLog(@"navigation controller disappeared");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidToggleMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSelectRewards object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSignOutNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (_menu && _menu.isOpen) {
        [_menu close];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
    goodListController = nil;
    userProfileController = nil;
    rewardListController = nil;
    exploreController = nil;
}

- (void)dealloc {
    DebugLog(@"dealloc");
}

- (void)toggleMenu {
    if (_menu.isOpen)
        return [_menu close];
    
    [_menu showFromNavigationController:self];
}

@end
