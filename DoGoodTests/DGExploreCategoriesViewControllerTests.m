#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "DGExploreCategoriesViewController.h"
#import "DGCategory.h"
#import "CategoryCell.h"
#import "DGViewController.h"
#import "DGGoodListViewController.h"

#pragma mark - Expose private methods & variables for testing with a category

@interface DGExploreCategoriesViewController (Tests)

- (void)setupRefresh;
- (void)refreshTable;
- (void)getCategories;

@end

@interface DGExploreCategoriesViewControllerTests : XCTestCase {
    DGExploreCategoriesViewController *controller;
    DGExploreCategoriesViewController * controllerMock;
}

@end

@implementation DGExploreCategoriesViewControllerTests

- (void)setUp {
    [super setUp];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Explore" bundle:nil];
    controller = [storyboard instantiateViewControllerWithIdentifier:@"exploreCategories"];
    controllerMock = OCMPartialMock(controller);
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - UIViewController

- (void)testViewDidLoad {
    [controller viewDidLoad];

    XCTAssertNotNil(controller.tableView.delegate);
    XCTAssertNotNil(controller.explorePopularTags);
    XCTAssertNotNil(controller.exploreHighlights);

    OCMVerify([controllerMock setupRefresh]);
    OCMVerify([controllerMock getCategories]);
}

#pragma mark - Custom methods

- (void)testSetupRefresh {
    [controller setupRefresh];
    XCTAssertNotNil(controller.refreshControl);
}

- (void)testRefreshTable {
    [controllerMock refreshTable];

    OCMVerify([controllerMock getCategories]);
    OCMVerify([controllerMock.refreshControl endRefreshing]);
}

#pragma mark - UITableViewDataSource

- (void)testCellForRowAtIndexPath {
    [controller viewDidLoad];

    DGCategory *category = [self addCategory];

    [controller.tableView reloadData];
    CategoryCell *cell = [self exploreCell];

    XCTAssertEqualObjects(category, cell.category);
}

- (void)testHeightForRowAtIndexPath {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    XCTAssertEqual(80, [controller tableView:controller.tableView heightForRowAtIndexPath:indexPath]);
}

- (void)testNumberOfRowsInSection {
    XCTAssertEqual([controller.categories count], [controller tableView:controller.tableView numberOfRowsInSection:0]);
}

- (void)testNumberOfSections {
    XCTAssertEqual(1, [controller numberOfSectionsInTableView:controller.tableView]);
}

#pragma mark - UITableViewDelegate

- (void)testDidSelectRowAtIndexPath {
    DGCategory *category = [self addCategory];

    id mockTableViewController = (id)controllerMock;
    id mockNavigationController = [OCMockObject niceMockForClass:[UINavigationController class]];
    [[[mockTableViewController stub] andReturn:mockNavigationController] navigationController];

    UIViewController *viewController = [OCMArg checkWithBlock:^BOOL(id obj) {
        DGGoodListViewController *vc = obj;
        return ([vc isKindOfClass:[DGGoodListViewController class]] && (vc.category == category));
    }];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    [[mockNavigationController expect] pushViewController:viewController animated:YES];

    [mockTableViewController tableView:[mockTableViewController tableView] didSelectRowAtIndexPath:indexPath];

    [mockTableViewController verify];
    [mockNavigationController verify];
}

#pragma mark - Helpers

- (CategoryCell *)exploreCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    CategoryCell *cell = (CategoryCell *)[controller tableView:controller.tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

- (DGCategory *)addCategory {
    DGCategory *category = [[DGCategory alloc] init];
    category.name = @"Environment";
    controller.categories = @[ category ];
    return category;
}

@end
