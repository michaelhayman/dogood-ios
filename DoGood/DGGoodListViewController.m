#import "DGGoodListViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
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
    } else {
        [self setupMenuTitle:@"Do Good"];
        [self addMenuButton:@"MenuFromHomeIconTap" withTapButton:@"MenuFromHomeIcon"];
    }

    UINib *nib = [UINib nibWithNibName:@"GoodCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"GoodCell"];

    [self setupUserPoints];
    [self getGood];
    [self setupRefresh];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showWelcome)
                                                 name:DGUserDidSignOutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getGood)
                                                 name:DGUserDidSignInNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getGood)
                                                 name:DGUserDidPostGood
                                               object:nil];
}

- (void)setupUserPoints {
    if (self.category == nil) {
    // if ([[DGUser currentUser].points intValue] > 0) {
        // UserOverview *userView = [[UserOverview alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        UserOverview *userView = [[UserOverview alloc] init];
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
    [tableView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getGood];
    [refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    DebugLog(@"appeared");
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"SignOut" object:self];
    [self showWelcome];
    [tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    DebugLog(@"disappeared");
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SignOut" object:nil];
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
    } else {
        path = @"/goods";
    }

    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        goods = [[NSArray alloc] initWithArray:mappingResult.array];
        [tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

@end

