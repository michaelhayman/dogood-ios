#import "DGUserProfileViewController.h"
#import "DGWelcomeViewController.h"
#import "DGUserSettingsViewController.h"
#import "DGGoodListViewController.h"
#import "DGUserListViewController.h"
#import "GoodCell.h"
#import "DGGood.h"

@interface DGUserProfileViewController ()

@end

@implementation DGUserProfileViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Profile";

    // assume it's the current user's profile if no ID was specified
    if (self.userID == nil) {
        self.userID = [DGUser currentUser].userID;
    }

    ownProfile = [self.userID isEqualToNumber:[DGUser currentUser].userID];
    DebugLog(@"own profile? %d %@ %@", ownProfile, self.userID, [DGUser currentUser].userID);

    // conditional settings on user
    UIBarButtonItem *connectButton;
    if (ownProfile) {
        [self addMenuButton:@"MenuFromHomeIcon" withTapButton:@"MenuFromHomeIconTap"];
        connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Find Friends" style: UIBarButtonItemStylePlain target:self action:@selector(findFriends:)];
        [centralButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
        [centralButton setTitle:@"Settings" forState:UIControlStateNormal];
    } else {
        // block menu options
        connectButton = [[UIBarButtonItem alloc] initWithTitle:@"..." style: UIBarButtonItemStylePlain target:self action:@selector(openActionMenu:)];

        [centralButton setBackgroundImage:[UIImage imageNamed:@"ProfileFollowButton"] forState:UIControlStateNormal];
        [centralButton setBackgroundImage:[UIImage imageNamed:@"ProfileFollowButtonTap"] forState:UIControlStateHighlighted];
        [centralButton setBackgroundImage:[UIImage imageNamed:@"ProfileFollowingButton"] forState:UIControlStateSelected];
        [centralButton setTitle:@"Follow" forState:UIControlStateNormal];
        [centralButton addTarget:self action:@selector(toggleFollow) forControlEvents:UIControlEventTouchUpInside];
    }
    self.navigationItem.rightBarButtonItem = connectButton;
    [self getProfile];

    /*
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    tableView.delegate = controller;
    tableView.dataSource = controller;
     */
    [tableView setTableHeaderView:headerView];
    UINib *nib = [UINib nibWithNibName:@"GoodCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"GoodCell"];
    // selectedTab = @"Goods";
    [self getUserGood];

    // setup following / followers text
    UITapGestureRecognizer* followersGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowers)];
    [followers setUserInteractionEnabled:YES];
    [followers addGestureRecognizer:followersGesture];

    UITapGestureRecognizer* followingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowing)];
    [following setUserInteractionEnabled:YES];
    [following addGestureRecognizer:followingGesture];
}

- (void)setupTabs {
    [goodsButton addTarget:self action:@selector(getUserGood) forControlEvents:UIControlEventTouchUpInside];
    [goodsButton setTitle:[NSString stringWithFormat:@"%@ GOODS", user.posted_or_followed_goods_count] forState:UIControlStateNormal];
    [likesButton addTarget:self action:@selector(getUserLikes) forControlEvents:UIControlEventTouchUpInside];
    [likesButton setTitle:[NSString stringWithFormat:@"%@ LIKES", user.liked_goods_count] forState:UIControlStateNormal];
}

- (void)getProfile {
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/users/%@", self.userID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        user = [DGUser new];
        user = mappingResult.array[0];

        followers.text = [NSString stringWithFormat:@"%@ FOLLOWERS", user.followers_count];
        following.text = [NSString stringWithFormat:@"%@ FOLLOWING", user.following_count];

        name.text = user.full_name;
        if ([user.current_user_following boolValue] == YES) {
            centralButton.selected = YES;
            [centralButton setBackgroundImage:[UIImage imageNamed:@"ProfileFollowingButtonTap"] forState:UIControlStateHighlighted];
            [centralButton setTitle:@"Following" forState:UIControlStateNormal];
        }
        [self setupTabs];

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL

                                                              URLWithString:user.avatar]

                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 
                                             timeoutInterval:60.0];
        [avatar setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            avatar.image = image;
            if (ownProfile) {
                avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
                [avatar bringSubviewToFront:avatarOverlay];
            }
        } failure:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

- (void)toggleFollow {
    DebugLog(@"shoe goes on");
}

- (void)openSettings {
    DebugLog(@"settings view");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserSettingsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Actions
- (IBAction)findFriends:(id)sender {

}

- (IBAction)openActionMenu:(id)sender {

}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"GoodCell";
    GoodCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGGood *good = goods[indexPath.row];
    cell.good = good;
    [cell setValues];
    cell.navigationController = self.navigationController;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 773;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [goods count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

#pragma mark - User listing links
- (void)showFollowers {
    [self userListWithType:@"User" typeID:user.userID andQuery:@"followers"];
}

- (void)showFollowing {
    [self userListWithType:@"User" typeID:user.userID andQuery:@"following"];
}

- (void)userListWithType:(NSString *)type typeID:(NSNumber *)typeID andQuery:(NSString *)query {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserList"];
    controller.typeID = typeID;
    controller.type = type;
    controller.query = query;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Good Listings
- (void)getUserGood {
    if (goodsButton.selected == NO) {
        [goodsButton setSelected:YES];
        [likesButton setSelected:NO];
        NSString *path = [NSString stringWithFormat:@"/goods/liked_by?user_id=%@", self.userID];
        [self getGoodsAtPath:path];
    }
}

- (void)getUserLikes {
    if (likesButton.selected == NO) {
        [goodsButton setSelected:NO];
        [likesButton setSelected:YES];
        NSString *path = [NSString stringWithFormat:@"/goods/posted_or_followed_by?user_id=%@", self.userID];
        [self getGoodsAtPath:path];
    }
}

- (void)getGoodsAtPath:(NSString *)path {
    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        goods = [[NSArray alloc] initWithArray:mappingResult.array];
        [tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

@end
