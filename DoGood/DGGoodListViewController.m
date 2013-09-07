#import "DGGoodListViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "FSLocation.h"
#import "DGWelcomeViewController.h"

@interface DGGoodListViewController ()

@end

@implementation DGGoodListViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Do Good"];

    [self addMenuButton:@"MenuFromHomeIcon" withTapButton:@"MenuFromHomeIconTap"];

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
    [[NSBundle mainBundle] loadNibNamed:@"UserOverview" owner:self options:nil];
    [tableView setTableHeaderView:headerView];

    UILabel *userName = (UILabel *)[headerView viewWithTag:201];
    userName.text = [DGUser currentUser].username;
    UILabel *points = (UILabel *)[headerView viewWithTag:202];
    points.text = [NSString stringWithFormat:@"%@ points", [DGUser currentUser].points];
    headerView.backgroundColor = [UIColor lightGrayColor];
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

#pragma mark - Retrieval methods
- (void)getGood {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/goods.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        goods = [[NSArray alloc] initWithArray:mappingResult.array];
        [tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

@end

