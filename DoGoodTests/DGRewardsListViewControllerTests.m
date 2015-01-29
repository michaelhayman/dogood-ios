#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "DGViewController.h"
#import "DGRewardsListViewController.h"

@interface DGRewardsListViewController (Tests)
- (void)setupTabs;
@end

@interface DGRewardsListViewControllerTests : XCTestCase {
    DGRewardsListViewController *controller;
    id controllerMock;
}

@end

@implementation DGRewardsListViewControllerTests

- (void)setUp {
    [super setUp];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Rewards" bundle:nil];
    controller = [storyboard instantiateViewControllerWithIdentifier:@"rewardList"];
    controllerMock = OCMPartialMock(controller);
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertEqualObjects(@"Rewards", controller.title);
    XCTAssertEqualObjects([UIImage imageNamed:@"tab_rewards"], controller.tabBarItem.image);
}

- (void)testViewDidLoad {
    [[controllerMock expect] setupTabs];
    [controller viewDidLoad];
    [[controllerMock verify] setupTabs];
}

@end
