#import "DGGoodListViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "DGTag.h"
#import "NoResultsCell.h"
#import "DGCategory.h"
#import "FSLocation.h"
#import "DGWelcomeViewController.h"
#import "UserOverview.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface DGGoodListViewController ()

@end

@implementation DGGoodListViewController

@synthesize tableView;

#define kGoodCaptionFont [UIFont systemFontOfSize:14.]

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

    showNoResultsMessage = NO;

    [self initializeTable];

    userView = [[UserOverview alloc] init];
    // userView = [[UserOverview alloc] initWithFrame:CGRectMake(0, 0, 320, 106)];
    [self setupUserPoints];
    // [self getGood];

    [[NSNotificationCenter defaultCenter] addObserver:userView selector:@selector(setContent) name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWelcome) name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayPostSuccessMessage) name:DGUserDidPostGood object:nil];
}

- (void)initializeTable {
    UINib *nib = [UINib nibWithNibName:@"GoodCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"GoodCell"];
    UINib *noResultsNib = [UINib nibWithNibName:@"NoResultsCell" bundle:nil];
    [tableView registerNib:noResultsNib forCellReuseIdentifier:@"NoResultsCell"];
    showNoResultsMessage = NO;
    goods = [[NSMutableArray alloc] init];
    cellHeights = [[NSMutableArray alloc] init];
    [self setupRefresh];
    [self setupInfiniteScroll];
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
    [self reloadGood];
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
        if ([goods count] == 0) {
            [self reloadGood];
        }
    }
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString * reuseIdentifier = @"GoodCell";
        GoodCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGGood *good = goods[indexPath.row];
        cell.good = good;
        cell.navigationController = self.navigationController;
        cell.parent = self;
        [cell setValues];
        DebugLog(@"set");
        return cell;
    } else {
        static NSString * reuseIdentifier = @"NoResultsCell";
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.explanation.text = @"No good found";
        return cell;
    }
}

/*
- (CGFloat)tableView:(UITableView *)aTableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 600;
}
*/

- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath withGood:(DGGood *)good {
    cellHeights[indexPath.row] = [self calculateHeightForGood:good];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSNumber *height = [cellHeights objectAtIndex:indexPath.row];
        return [height floatValue];
    } else {
        return 205;
    }
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [goods count];
    } else {
        if (showNoResultsMessage == YES) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

#pragma mark - Retrieval methods
- (void)getGood {
    NSString *path;
    DebugLog(@"self path %@", self.path);
    if (self.path) {
        path = self.path;
    } else if (_category) {
        path = [NSString stringWithFormat:@"/goods?category_id=%@", _category.categoryID];
    } else if (_goodID) {
        path = [NSString stringWithFormat:@"/goods?good_id=%@", _goodID];
    } else if (_tag) {
        path = [NSString stringWithFormat:@"/goods/tagged?id=%@&name=%@", _tag.tagID, _tag.name];
    } else {
        path = @"/goods";
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page], @"page", nil];

    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [goods addObjectsFromArray:mappingResult.array];
        if ([goods count] == 0)  {
            showNoResultsMessage = YES;
        } else {
            showNoResultsMessage = NO;
            [self estimateHeightsForGoods:mappingResult.array];
        }
        DebugLog(@"goods %@", goods);
        [tableView reloadData];
        [tableView.infiniteScrollingView stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self.navigationController title:@"Oops" subtitle:[error localizedDescription] type:TSMessageNotificationTypeError];
        [tableView.infiniteScrollingView stopAnimating];
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

- (void)loadMoreGood {
    page++;
    [self getGood];
}

- (void)resetGood {
    page = 1;
    [goods removeAllObjects];
    [cellHeights removeAllObjects];
}

- (void)reloadGood {
    DebugLog(@"reload good");
    [self resetGood];
    [self getGood];
    [tableView reloadData];
}

- (void)setupInfiniteScroll {
    tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    __weak DGGoodListViewController *self_ = self;
    [tableView addInfiniteScrollingWithActionHandler:^{
        [tableView.infiniteScrollingView startAnimating];
        [self_ loadMoreGood];
    }];
}

#pragma mark - Cell heights
- (void)estimateHeightsForGoods:(NSArray *)goodList {
    for (DGGood *good in goodList) {
        [cellHeights addObject:[self calculateHeightForGood:good]];
    }
}

- (NSNumber *)calculateHeightForGood:(DGGood *)good {
    CGFloat height = 110;

    NSDictionary *attributes = @{NSFontAttributeName : kGoodCaptionFont};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:good.caption attributes:attributes];

    CGFloat captionHeight = [GoodCell calculateHeightForText:attrString];
    height += captionHeight;

    if (good.evidence) {
        height+= 300;
    }
    if (good.location_name) {
        height += 20;
    }
    if (good.category) {
        height += 20;
    }
    if (good.comments) {
        height += [good.comments count] * 20;
        height += 30;
    }
    if ([good.likes_count intValue] > 0) {
        height += 30;
    }
    if ([good.regoods_count intValue] > 0) {
        height += 30;
    }
    return [NSNumber numberWithFloat:height];
}

@end

