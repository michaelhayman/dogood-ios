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
    self.showNoResultsMessage = NO;
    self.goods = [[NSMutableArray alloc] init];
    self.cellHeights = [[NSMutableArray alloc] init];

    self.loadingView = [[SAMLoadingView alloc] initWithFrame:self.bounds];
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    [button setTitleColor:[DGAppearance makeContrastingColorFromColor:self.tabColor] forState:UIControlStateNormal];

    return button;
}

- (void)showTabsWithColor:(UIColor *)color {
    self.tabColor = color;

    self.all = [self tabButtonWithWidth:60 andOffset:0];
    [self.all setTitle:@"All" forState:UIControlStateNormal];
    self.all.tag = 101;

    self.done = [self tabButtonWithWidth:130 andOffset:60];
    [self.done setTitle:@"Nominations" forState:UIControlStateNormal];
    self.done.tag = 102;

    self.todo = [self tabButtonWithWidth:130 andOffset:190];
    [self.todo setTitle:@"Help Wanted" forState:UIControlStateNormal];
    self.todo.tag = 103;

    self.tabsShowing = YES;

    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    tableHeaderView.backgroundColor = color;
    [tableHeaderView addSubview:self.all];
    [tableHeaderView addSubview:self.done];
    [tableHeaderView addSubview:self.todo];
    self.tableHeaderView = tableHeaderView;

    [self chooseAll];

    self.loadingView.frame = CGRectMake(self.loadingView.frame.origin.x, self.loadingView.frame.origin.y + self.tableHeaderView.frame.size.height, self.loadingView.frame.size.width, self.loadingView.frame.size.height);
}

- (IBAction)chooseTab:(id)sender {
    UIButton *button = (UIButton *)sender;

    if (button.tag == 102) {
        if (![button isSelected]) {
            [self chooseDone];
            [self resetGood];
            [self loadGoodsAtPath:self.goodsPath];
        }
    } else if (button.tag == 103) {
        if (![button isSelected]) {
            [self chooseTodo];
            [self resetGood];
            [self loadGoodsAtPath:self.goodsPath];
        }
    } else {
        if (![button isSelected]) {
            [self chooseAll];
            [self resetGood];
            [self loadGoodsAtPath:self.goodsPath];
        }
    }
}

- (void)resetButtons {
    self.all.selected = NO;
    self.done.selected = NO;
    self.todo.selected = NO;
    self.all.backgroundColor = self.tabColor;
    self.done.backgroundColor = self.tabColor;
    self.todo.backgroundColor = self.tabColor;
}

- (void)chooseAll {
    [self resetButtons];
    self.doneGoods = allTab;
    self.all.selected = YES;
    self.all.backgroundColor = [UIColor whiteColor];
}

- (void)chooseDone {
    [self resetButtons];
    self.doneGoods = doneTab;
    self.done.selected = YES;
    self.done.backgroundColor = [UIColor whiteColor];
}

- (void)chooseTodo {
    [self resetButtons];
    self.doneGoods = helpWantedTab;
    self.todo.selected = YES;
    self.todo.backgroundColor = [UIColor whiteColor];
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
    self.goodsPath = path;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.page], @"page", nil];

    if (self.tabsShowing) {
        if ([self.done isSelected]) {
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"done"];
        } else if ([self.todo isSelected]) {
            [params setObject:[NSNumber numberWithBool:NO] forKey:@"done"];
        }
    }

    [DGGood getGoodsAtPath:path withParams:params completion:^(NSArray *goods, NSError *error) {
        if (error) {
            [self.infiniteScrollingView stopAnimating];
            [ProgressHUD showError:[error localizedDescription]];
            DebugLog(@"Operation failed with error: %@", error);
            [self reloadData];
            [self.loadingView removeFromSuperview];

            return;
        }

        [self.goods addObjectsFromArray:goods];

        if ([self.goods count] == 0)  {
            self.showNoResultsMessage = YES;
        } else {
            self.showNoResultsMessage = NO;
            [self estimateHeightsForGoods:goods];
        }

        [self reloadData];
        [self.infiniteScrollingView stopAnimating];
        [self.loadingView removeFromSuperview];
    }];
}

- (void)loadMoreGood {
    self.page++;
    [self loadGoodsAtPath:self.goodsPath];
}

- (void)resetGood {
    self.page = 1;
    [self addSubview:self.loadingView];
    [self.goods removeAllObjects];
    [self.cellHeights removeAllObjects];
}

- (void)reloadGood {
    [self resetGood];
    [self loadGoodsAtPath:self.goodsPath];
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
        [self.cellHeights addObject:[good calculateHeight]];
    }
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        NSString * reuseIdentifier = [self cellName];
        GoodCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGGood *good = self.goods[indexPath.row];
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
    self.cellHeights[indexPath.row] = [good calculateHeight];
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSNumber *height = [self.cellHeights objectAtIndex:indexPath.row];
        return [height floatValue];
    } else {
        return kNoResultsCellHeight;
    }
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.goods count];
    } else {
        if (self.showNoResultsMessage == YES) {
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
