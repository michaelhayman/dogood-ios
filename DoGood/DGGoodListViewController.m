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
#import "DGAppearance.h"
#import "DGComment.h"
#import "DGLoadingView.h"

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
    } else if (_path) {
        [self setupMenuTitle:_titleForPath];
    } else {
        [self setupMenuTitle:@"Good Done"];
        [self addMenuButton:@"MenuFromHomeIconTap" withTapButton:@"MenuFromHomeIcon"];
    }

    showNoResultsMessage = NO;
    self.navigationController.navigationBar.barTintColor = VIVID;

    [self initializeTable];
    [self setupRefresh];
    [self setupInfiniteScroll];

    [self setupUserPoints];

    if (!self.loadController) {
        self.loadController = self.navigationController;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)dealloc {
    DebugLog(@"dealloc called");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(welcomeScreen) name:DGUserDidFailSilentAuthenticationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:userView selector:@selector(setContent) name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWelcome) name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayPostSuccessMessage) name:DGUserDidPostGood object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGood) name:DGUserDidPostGood object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidFailSilentAuthenticationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:userView name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidPostGood object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showWelcome];
//    [tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)initializeTable {
    UINib *nib = [UINib nibWithNibName:@"GoodCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"GoodCell"];
    UINib *noResultsNib = [UINib nibWithNibName:@"NoResultsCell" bundle:nil];
    [_tableView registerNib:noResultsNib forCellReuseIdentifier:@"NoResultsCell"];
    showNoResultsMessage = NO;
    goods = [[NSMutableArray alloc] init];
    cellHeights = [[NSMutableArray alloc] init];
    _loadingView = [[DGLoadingView alloc] initCenteredOnView:_tableView];
}

- (void)displayPostSuccessMessage {
    [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Saved!", nil) subtitle:NSLocalizedString(@"You made some points!", nil) type:TSMessageNotificationTypeSuccess];
}

- (void)setupUserPoints {
    if (_category == nil && _tag == nil && _path == nil) {
        userView = [[UserOverview alloc] initWithController:self.navigationController];
        [_tableView setTableHeaderView:userView];
    }
}

- (void)setupRefresh {
    UIRefreshControl *refreshControl = [UIRefreshControl new];

    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = COLOUR_GREEN;
    [_tableView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self reloadGood];
    [userView setContent];
    [refreshControl endRefreshing];
}

#pragma mark - Points
- (void)showWelcome {
    if (![[DGUser currentUser] isSignedIn]) {
        // [self welcomeScreen];
    } else {
        if ([goods count] == 0) {
            [self reloadGood];
        }
    }
}

- (void)welcomeScreen {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString * reuseIdentifier = @"GoodCell";
        GoodCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGGood *good = goods[indexPath.row];
        cell.good = good;
        cell.navigationController = self.loadController;
        cell.parent = self;
        [cell setValues];
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
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    DebugLog(@"path ...? %@", _path);
    if (_path) {
        path = _path;
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
        [_tableView reloadData];
        [_tableView.infiniteScrollingView stopAnimating];
        [_loadingView loadingSucceeded];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_tableView.infiniteScrollingView stopAnimating];
        DebugLog(@"Operation failed with error: %@", error);
        [_loadingView loadingFailed];
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
    [_tableView reloadData];
}

- (void)reloadGood {
    [_loadingView startLoading];
    [self resetGood];
    [self getGood];
}

- (void)setupInfiniteScroll {
    _tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    __weak DGGoodListViewController *weakSelf = self;
    __weak UITableView *weakTableView = _tableView;

    [_tableView addInfiniteScrollingWithActionHandler:^{
        __strong DGGoodListViewController *strongSelf = weakSelf;
        __strong UITableView *strongTableView = weakTableView;
        [strongTableView.infiniteScrollingView startAnimating];
        [strongSelf loadMoreGood];
    }];
}

#pragma mark - Cell heights
- (void)estimateHeightsForGoods:(NSArray *)goodList {
    for (DGGood *good in goodList) {
        [cellHeights addObject:[self calculateHeightForGood:good]];
    }
}

// move to model
- (NSNumber *)calculateHeightForGood:(DGGood *)good {
    CGFloat height = 110;

    NSDictionary *attributes = @{NSFontAttributeName : kGoodCaptionFont};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:good.caption attributes:attributes];

    CGFloat captionHeight = [DGAppearance calculateHeightForText:attrString andWidth:kGoodRightColumnWidth];
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
        height += 40;
        for (DGComment *comment in good.comments) {
            NSDictionary *commentAttributes = @{ NSFontAttributeName : kSummaryCommentFont };
            NSAttributedString *attrCommentString = [[NSAttributedString alloc] initWithString:[comment.user.full_name stringByAppendingString:comment.comment] attributes:commentAttributes];
            CGFloat commentHeight = [DGAppearance calculateHeightForText:attrCommentString andWidth:kSummaryCommentRightColumnWidth];
            height += commentHeight;
        }
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

