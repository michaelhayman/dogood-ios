#import "GoodTableView.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "NoResultsCell.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "DGAppearance.h"
#import "DGComment.h"
#import <SAMLoadingView/SAMLoadingView.h>

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
    UINib *nib = [UINib nibWithNibName:@"GoodCell" bundle:nil];
    [self registerNib:nib forCellReuseIdentifier:@"GoodCell"];
    UINib *noResultsNib = [UINib nibWithNibName:kNoResultsCell bundle:nil];
    [self registerNib:noResultsNib forCellReuseIdentifier:kNoResultsCell];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    showNoResultsMessage = NO;
    goods = [[NSMutableArray alloc] init];
    cellHeights = [[NSMutableArray alloc] init];

    [self chooseDone];

    loadingView = [[SAMLoadingView alloc] initWithFrame:self.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)showTabs {
    [self showTabsWithColor:VIVID];
}

- (UIButton *)tabButtonWithOffset:(CGFloat)offset {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(offset, 0, 160, 30)];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    [button addTarget:self action:@selector(chooseTab:) forControlEvents:UIControlEventTouchUpInside];
    button.userInteractionEnabled = YES;
    [button setTitleColor:MUD forState:UIControlStateSelected];
    [button setTitleColor:[DGAppearance makeContrastingColorFromColor:tabColor] forState:UIControlStateNormal];

    return button;
}

- (void)showTabsWithColor:(UIColor *)color {
    tabColor = color;

    done = [self tabButtonWithOffset:0];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    done.tag = 0;
    done.selected = YES;

    todo = [self tabButtonWithOffset:160];
    todo.tag = 1;
    [todo setTitle:@"To Do" forState:UIControlStateNormal];

    tabsShowing = YES;

    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [tableHeaderView addSubview:done];
    [tableHeaderView addSubview:todo];
    self.tableHeaderView = tableHeaderView;

    [self chooseDone];
}

- (IBAction)chooseTab:(id)sender {
    UIButton *button = (UIButton *)sender;

    if (button.tag == 0) {
        if (!doneGoods) {
            [self chooseDone];
            [self resetGood];
            [self loadGoodsAtPath:goodsPath];
        }
    } else {
        if (doneGoods) {
            [self chooseTodo];
            [self resetGood];
            [self loadGoodsAtPath:goodsPath];
        }
    }

}

- (void)chooseDone {
    doneGoods = YES;
    todo.selected = NO;
    done.selected = YES;
    todo.backgroundColor = tabColor;
    done.backgroundColor = [UIColor whiteColor];
}

- (void)chooseTodo {
    doneGoods = NO;
    done.selected = NO;
    todo.selected = YES;
    done.backgroundColor = tabColor;
    todo.backgroundColor = [UIColor whiteColor];
}

- (void)setupRefresh {
    UIRefreshControl *refreshControl = [UIRefreshControl new];

    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = COLOUR_GREEN;
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
        [params setObject:[NSNumber numberWithBool:doneGoods] forKey:@"done"];
    }

    [self addSubview:loadingView];

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
        DebugLog(@"Operation failed with error: %@", error);
        [loadingView removeFromSuperview];
    }];
}

- (void)getGood {
    [self loadGoodsAtPath:goodsPath];
}

- (void)loadMoreGood {
    page++;
    [self getGood];
}

- (void)resetGood {
    page = 1;
    [goods removeAllObjects];
    [cellHeights removeAllObjects];
    [self reloadData];
}

- (void)reloadGood {
    // [_loadingView startLoading];
    [self resetGood];
    [self getGood];
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

    NSAttributedString *postedByAttrString = [[NSAttributedString alloc] initWithString:[good postedByLine] attributes:attributes];
    CGFloat postedByHeight = [DGAppearance calculateHeightForText:postedByAttrString andWidth:kGoodRightColumnWidth];
    height += postedByHeight;

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

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString * reuseIdentifier = @"GoodCell";
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
    cellHeights[indexPath.row] = [self calculateHeightForGood:good];
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
