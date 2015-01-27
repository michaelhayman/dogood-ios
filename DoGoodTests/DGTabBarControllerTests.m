#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "DGTabBarController.h"
#import "DGViewController.h"
#import "DGUser.h"
#import "DGUserProfileViewController.h"

@interface DGTabBarControllerTests : XCTestCase {
    DGTabBarController *controller;
}

@end

@implementation DGTabBarControllerTests

- (void)setUp {
    [super setUp];
    controller = [[DGTabBarController alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitialization {
    XCTAssertEqual(3, [controller.viewControllers count]);
}

- (void)testDidSelectViewController {
    DGUserProfileViewController *profileController = [[DGUserProfileViewController alloc] init];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:profileController];

    [controller tabBarController:controller didSelectViewController:nav];
    XCTAssertTrue(profileController.fromMenu);
}

@end
