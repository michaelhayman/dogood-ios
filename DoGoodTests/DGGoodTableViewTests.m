#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "GoodTableView.h"
#import "NoResultsCell.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "constants.h"

@interface GoodTableView (Tests)

- (UIButton *)tabButtonWithWidth:(CGFloat)width andOffset:(CGFloat)offset;
- (void)chooseAll;
- (void)chooseDone;
- (void)chooseTodo;
- (void)estimateHeightsForGoods:(NSArray *)goodList;
- (void)loadMoreGood;
- (void)reloadGood;
- (void)refresh:(UIRefreshControl *)refresh;
- (void)resetButtons;
- (IBAction)chooseTab:(id)sender;

@end

@interface DGGoodTableViewTests : XCTestCase {
    GoodTableView *tableView;
}

@end

@implementation DGGoodTableViewTests

- (void)setUp {
    [super setUp];
    tableView = [[GoodTableView alloc] initWithCoder:nil];
    tableView.goodsPath = @"/goods";
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Initialization

- (void)testInitialization {
    XCTAssertNotNil(tableView.delegate);
}

#pragma mark - Custom methods

- (void)testTabButton {
    CGFloat offset = 5;
    CGFloat width = 50;
    UIButton *button = [tableView tabButtonWithWidth:width andOffset:offset];

    XCTAssertNotNil(button);
    XCTAssertEqual(offset, button.frame.origin.x);
    XCTAssertEqual(width, button.frame.size.width);
}

- (void)testShowTabs {
    XCTAssertNil(tableView.tableHeaderView);
    [tableView showTabsWithColor:[UIColor redColor]];
    XCTAssertNotNil(tableView.tableHeaderView);
}

- (void)testChooseTab {
    id goodMock = OCMClassMock([DGGood class]);
    [[[goodMock expect] classMethod] getGoodsAtPath:[OCMArg isNotNil] withParams:[OCMArg isNotNil] completion:[OCMArg any]];

    [tableView showTabs];
    [tableView chooseTab:tableView.done];

    XCTAssertTrue([tableView.done isSelected]);

    [goodMock verify];

    [goodMock stopMocking];
}

- (void)testChooseAll {
    [tableView chooseAll];
    XCTAssertEqual(allTab, tableView.doneGoods);
}

- (void)testChooseDone {
    [tableView chooseDone];
    XCTAssertEqual(doneTab, tableView.doneGoods);
}

- (void)testChooseTodo {
    [tableView chooseTodo];
    XCTAssertEqual(helpWantedTab, tableView.doneGoods);
}

- (void)testResetButtons {
    [tableView resetButtons];

    XCTAssertFalse([tableView.all isSelected]);
    XCTAssertEqualObjects(tableView.tabColor, tableView.all.backgroundColor);
}

- (void)testSetupRefresh {
    [tableView setupRefresh];

    BOOL refreshControlFound;

    for (UIView *view in tableView.subviews) {
        if ([view isKindOfClass:[UIRefreshControl class]]) {
            refreshControlFound = YES;
        }
    }
    XCTAssertTrue(refreshControlFound, @"UITableView must have a UIRefreshControl subview.");
}

- (void)testRefresh {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh beginRefreshing];
    XCTAssertTrue([refresh isRefreshing]);

    [tableView refresh:refresh];

    XCTAssertFalse([refresh isRefreshing]);
}

- (void)testGetGoods {
    id goodMock = OCMClassMock([DGGood class]);
    NSString *path = @"/foo";

    [[[goodMock expect] classMethod] getGoodsAtPath:path withParams:[OCMArg isNotNil] completion:[OCMArg any]];

    [tableView loadGoodsAtPath:path];

    XCTAssertEqualObjects(path, tableView.goodsPath);

    [goodMock verify];

    [goodMock stopMocking];
}

- (void)testLoadMoreGood {
    int page = 5;
    tableView.page = page;
    [tableView loadMoreGood];
    XCTAssertEqual(6, tableView.page);
}

- (void)testResetGood {
    tableView.page = 5;
    [tableView resetGood];
    XCTAssertEqual(1, tableView.page);
}

- (void)testReloadGood {
    id mockTableView = OCMPartialMock(tableView);

    [[mockTableView expect] resetGood];

    [tableView reloadGood];

    [[mockTableView verify] resetGood];

    [mockTableView stopMocking];
}

- (void)testEstimateHeightsForGood {
    [self addGood];

    [tableView estimateHeightsForGoods:tableView.goods];

    XCTAssertEqualObjects(@107, [tableView.cellHeights firstObject]);
}

#pragma mark - UITableViewDataSource

// TODO: Figure out why this doesn't work
- (void)DISABLED_testCellForRowAtIndexPathWhenEmptyAndShowNoResults {
    tableView.showNoResultsMessage = YES;

    [tableView reloadData];
    XCTAssertEqual(1, [tableView numberOfRowsInSection:1]);

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NoResultsCell *cell = (NoResultsCell *)[tableView cellForRowAtIndexPath:indexPath];
    XCTAssertTrue([cell isKindOfClass:[NoResultsCell class]]);
}

- (void)testCellForRowAtIndexPathWhenEmptyAndDontShowNoResults {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    XCTAssertNil(cell);
}

- (void)testCellForRowAtIndexPath {
    DGGood *good = [self addGood];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    GoodCell *cell = (GoodCell *)[tableView cellForRowAtIndexPath:indexPath];

    XCTAssertEqualObjects(good, cell.good);
}

// TODO: this method is not used because it causes an error.
- (void)DISABLED_testReloadCell {
    DGGood * good = [self addGood];
    id tableViewMock = OCMClassMock([GoodTableView class]);

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[tableViewMock expect] reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];

    [tableView reloadCellAtIndexPath:indexPath withGood:good];

    [tableViewMock verify];
}

- (void)testHeightForRow {
    NSIndexPath *noResultsPath = [NSIndexPath indexPathForRow:0 inSection:1];
    XCTAssertEqual(kNoResultsCellHeight, [tableView tableView:tableView heightForRowAtIndexPath:noResultsPath]);

    [self addGood];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    XCTAssertEqual(107, [tableView tableView:tableView heightForRowAtIndexPath:indexPath]);
}

#pragma mark - UITableViewDelegate

- (void)testNumberOfRows {
    XCTAssertEqual(0, [tableView numberOfRowsInSection:1]);
    tableView.showNoResultsMessage = YES;
    [tableView reloadData];
    XCTAssertEqual(1, [tableView numberOfRowsInSection:1]);

    [self addGood];

    XCTAssertEqual(1, [tableView numberOfRowsInSection:0]);
}

- (void)testNumberOfSections {
    XCTAssertEqual(2, [tableView numberOfSectionsInTableView:tableView]);
}

- (void)testTitleForHeader {
    XCTAssertEqualObjects(@"", [tableView tableView:tableView titleForHeaderInSection:0]);
}

- (void)testHeightForFooter {
    XCTAssertEqual(0.01f, [tableView tableView:tableView heightForFooterInSection:0]);
}

#pragma mark - Helper methods

- (DGGood *)addGood {
    DGGood *good = [[DGGood alloc] init];

    [tableView.goods addObject:good];
    [tableView estimateHeightsForGoods:tableView.goods];
    [tableView reloadData];

    return good;
}

@end
