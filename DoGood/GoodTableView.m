#import "GoodTableView.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "DGGood+Dimensions.h"
#import "NoResultsCell.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "DGComment.h"
#import <SAMLoadingView/SAMLoadingView.h>
#import <ProgressHUD/ProgressHUD.h>

@implementation GoodTableView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;

        [self initializeTable];
    }
    return self;
}

- (void)initializeTable {
    UINib *nib = [UINib nibWithNibName:[self cellName] bundle:nil];
    [self registerNib:nib forCellReuseIdentifier:[self cellName]];
    UINib *noResultsNib = [UINib nibWithNibName:kNoResultsCell bundle:nil];
    [self registerNib:noResultsNib forCellReuseIdentifier:kNoResultsCell];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    showNoResultsMessage = NO;
    goods = [[NSMutableArray alloc] init];
    cellHeights = [[NSMutableArray alloc] init];

    loadingView = [[SAMLoadingView alloc] initWithFrame:self.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (NSString *)cellName {
    if (iPad) {
        return @"GoodCellWide";
    } else {
        return @"GoodCell";
    }
}

- (void)showTabs {
    [self showTabsWithColor:VIVID];
}

- (UIButton *)tabButtonWithWidth:(CGFloat)width andOffset:(CGFloat)offset {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(offset, 0, width, 30)];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    [button addTarget:self action:@selector(chooseTab:) forControlEvents:UIControlEventTouchUpInside];
    button.userInteractionEnabled = YES;
    [button setTitleColor:MUD forState:UIControlStateSelected];
    [button setTitleColor:[DGAppearance makeContrastingColorFromColor:tabColor] forState:UIControlStateNormal];

    return button;
}

- (void)showTabsWithColor:(UIColor *)color {
    tabColor = color;

    all = [self tabButtonWithWidth:60 andOffset:0];
    [all setTitle:@"All" forState:UIControlStateNormal];
    all.tag = 101;

    done = [self tabButtonWithWidth:130 andOffset:60];
    [done setTitle:@"Nominations" forState:UIControlStateNormal];
    done.tag = 102;

    todo = [self tabButtonWithWidth:130 andOffset:190];
    [todo setTitle:@"Help Wanted" forState:UIControlStateNormal];
    todo.tag = 103;

    tabsShowing = YES;

    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [tableHeaderView addSubview:all];
    [tableHeaderView addSubview:done];
    [tableHeaderView addSubview:todo];
    self.tableHeaderView = tableHeaderView;

    [self chooseAll];

    loadingView.frame = CGRectMake(loadingView.frame.origin.x, loadingView.frame.origin.y + self.tableHeaderView.frame.size.height, loadingView.frame.size.width, loadingView.frame.size.height);
}

- (IBAction)chooseTab:(id)sender {
    UIButton *button = (UIButton *)sender;

    if (button.tag == 102) {
        if (![button isSelected]) {
            [self chooseDone];
            [self resetGood];
            [self loadGoodsAtPath:goodsPath];
        }
    } else if (button.tag == 103) {
        if (![button isSelected]) {
            [self chooseTodo];
            [self resetGood];
            [self loadGoodsAtPath:goodsPath];
        }
    } else {
        if (![button isSelected]) {
            [self chooseAll];
            [self resetGood];
            [self loadGoodsAtPath:goodsPath];
        }
    }
}

- (void)resetButtons {
    all.selected = NO;
    done.selected = NO;
    todo.selected = NO;
    all.backgroundColor = tabColor;
    done.backgroundColor = tabColor;
    todo.backgroundColor = tabColor;
}

- (void)chooseAll {
    [self resetButtons];
    self.doneGoods = allTab;
    all.selected = YES;
    all.backgroundColor = [UIColor whiteColor];
}

- (void)chooseDone {
    [self resetButtons];
    self.doneGoods = doneTab;
    done.selected = YES;
    done.backgroundColor = [UIColor whiteColor];
}

- (void)chooseTodo {
    [self resetButtons];
    self.doneGoods = helpWantedTab;
    todo.selected = YES;
    todo.backgroundColor = [UIColor whiteColor];
}

- (void)setupRefresh {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = VIVID;

    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self reloadGood];
    [refreshControl endRefreshing];
}

- (void)loadGoodsAtPath:(NSString *)path {
    goodsPath = path;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page], @"page", nil];

    if (tabsShowing) {
        if ([done isSelected]) {
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"done"];
        } else if ([todo isSelected]) {
            [params setObject:[NSNumber numberWithBool:NO] forKey:@"done"];
        }
    }

    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [goods addObjectsFromArray:mappingResult.array];
        if ([goods count] == 0)  {
            showNoResultsMessage = YES;
        } else {
            showNoResultsMessage = NO;
            [self estimateHeightsForGoods:mappingResult.array];
        }
        [self reloadData];
        [self.infiniteScrollingView stopAnimating];
        [loadingView removeFromSuperview];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.infiniteScrollingView stopAnimating];
        [ProgressHUD showError:[error localizedDescription]];
        DebugLog(@"Operation failed with error: %@", error);
        [self reloadData];
        [loadingView removeFromSuperview];
    }];
}

- (void)loadMoreGood {
    page++;
    [self loadGoodsAtPath:goodsPath];
}

- (void)resetGood {
    page = 1;
    [self addSubview:loadingView];
    [goods removeAllObjects];
    [cellHeights removeAllObjects];
}

- (void)reloadGood {
    [self resetGood];
    [self loadGoodsAtPath:goodsPath];
}

- (void)setupInfiniteScroll {
    self.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    __weak GoodTableView *weakSelf = self;

    [self addInfiniteScrollingWithActionHandler:^{
        __strong GoodTableView *strongSelf = weakSelf;
        [strongSelf.infiniteScrollingView startAnimating];
        [strongSelf loadMoreGood];
    }];
}

#pragma mark - Cell heights
- (void)estimateHeightsForGoods:(NSArray *)goodList {
    for (DGGood *good in goodList) {
        [cellHeights addObject:[good calculateHeight]];
    }
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString * reuseIdentifier = [self cellName];
        GoodCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGGood *good = goods[indexPath.row];
        cell.good = good;
        cell.navigationController = self.navigationController;
        cell.parent = self.parent;
        [cell setValues];
        return cell;
    } else {
        static NSString * reuseIdentifier = kNoResultsCell;
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        [cell setHeading:@"No posts found" explanation:@"Add something good with the + button up there" andImage:[UIImage imageNamed:@"NoPosts"]];
        return cell;
    }
}

/*
- (CGFloat)tableView:(UITableView *)aTableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 600;
}
*/

- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath withGood:(DGGood *)good {
    cellHeights[indexPath.row] = [good calculateHeight];
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSNumber *height = [cellHeights objectAtIndex:indexPath.row];
        return [height floatValue];
    } else {
        return kNoResultsCellHeight;
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

@end
