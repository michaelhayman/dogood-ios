#import "DGGoodListViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "DGTag.h"
#import "DGCategory.h"
#import "FSLocation.h"
#import "DGWelcomeViewController.h"
#import "UserOverview.h"

@interface DGGoodListViewController ()

@end

@implementation DGGoodListViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if (_category) {
        [self setupMenuTitle:_category.name];
    } else if (_tag) {
       [self setupMenuTitle:[_tag hashifiedName]];
    } else {
        [self setupMenuTitle:@"Do Good"];
        [self addMenuButton:@"MenuFromHomeIconTap" withTapButton:@"MenuFromHomeIcon"];
    }

    UINib *nib = [UINib nibWithNibName:@"GoodCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"GoodCell"];

    userView = [[UserOverview alloc] init];
    // userView = [[UserOverview alloc] initWithFrame:CGRectMake(0, 0, 320, 106)];
    [self setupUserPoints];
    // [self getGood];
    [self setupRefresh];

    [[NSNotificationCenter defaultCenter] addObserver:userView selector:@selector(setContent) name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWelcome) name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayPostSuccessMessage) name:DGUserDidPostGood object:nil];
}

- (void)displayPostSuccessMessage {
    [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Saved!", nil) subtitle:NSLocalizedString(@"You made some points!", nil) type:TSMessageNotificationTypeSuccess];
}

- (void)setupUserPoints {
    if (self.category == nil && self.tag == nil) {
    // if ([[DGUser currentUser].points intValue] > 0) {
        // UserOverview *userView = [[UserOverview alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        // userView.backgroundColor = [UIColor blackColor];
        [tableView setTableHeaderView:userView];
        // tableView.tableHeaderView.backgroundColor = [UIColor redColor];
        DebugLog(@"setting points");
    // }
    }
}

- (void)setupRefresh {
    UIRefreshControl *refreshControl = [UIRefreshControl new];

    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = COLOUR_GREEN;
    [tableView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getGood];
    [refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DebugLog(@"appeared");
    [self showWelcome];
    [tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DebugLog(@"disappeared");
}

#pragma mark - Points
- (void)showWelcome {
    DebugLog(@"show welcome");
    if (![[DGUser currentUser] isSignedIn]) {
        DebugLog(@"shouldn't be signed in");
        UIStoryboard *storyboard;
        storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
        DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
        [self presentViewController:navigationController animated:NO completion:nil];
    } else {
        [self getGood];
    }
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"GoodCell";
    GoodCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGGood *good = goods[indexPath.row];
    cell.good = good;
    cell.navigationController = self.navigationController;
    cell.parent = self;
    [cell setValues];
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 600;
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

#pragma mark - Retrieval methods
- (void)getGood {
    NSString *path;
    if (_category) {
        path = [NSString stringWithFormat:@"/goods?category_id=%@", _category.categoryID];
    } else if (_goodID) {
        path = [NSString stringWithFormat:@"/goods?good_id=%@", _goodID];
    } else if (_tag) {
        path = [NSString stringWithFormat:@"/goods/tagged_by_id?id=%@", _tag.tagID];
    } else {
        path = @"/goods";
    }

    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        goods = [[NSArray alloc] initWithArray:mappingResult.array];
        [tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self.navigationController title:@"Oops" subtitle:[error localizedDescription] type:TSMessageNotificationTypeError];
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

@end

