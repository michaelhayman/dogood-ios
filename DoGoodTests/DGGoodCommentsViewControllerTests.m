#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
@import UIKit;
#import "DGViewController.h"
#import "DGGoodCommentsViewController.h"
//    #import "constants.h"
//   #import "DGAppearance.h"
//   #import "UIViewController+DGViewController.h"

#pragma mark - Category interface (private methods)

@interface DGGoodCommentsViewController (Tests)

- (void)setupInfiniteScroll;
- (void)reloadComments;
- (void)setupKeyboardBehaviour;

@end

#pragma mark - Test interface

@interface DGGoodCommentsViewControllerTests : XCTestCase {
    DGGoodCommentsViewController *controller;
    DGGoodCommentsViewController *commentControllerMock;
    UINavigationController *nav;
}

@end


@implementation DGGoodCommentsViewControllerTests

#pragma mark - Set up & tear down

- (void)setUp {
    [super setUp];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodComments"];
    nav = [[UINavigationController alloc] initWithRootViewController:controller];
    commentControllerMock = OCMPartialMock(controller);
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Test methods

- (void)testViewDidLoad {
    [commentControllerMock viewDidLoad];

    // XCTAssertTrue(controller.sendButton.enabled);

    OCMVerify([commentControllerMock setupInfiniteScroll]);
    OCMVerify([commentControllerMock reloadComments]);
}

- (void)testViewWillAppear {
    [commentControllerMock viewWillAppear:YES];

    OCMVerify([commentControllerMock setupKeyboardBehaviour]);
}

- (void)testTextFieldDidBeginEditing {
    [commentControllerMock textViewDidBeginEditing:[[UITextView alloc] init]];

    XCTAssertNotNil(commentControllerMock.navigationItem.rightBarButtonItem);
}

- (void)testTextFieldDidEndEditing {
    [commentControllerMock textViewDidEndEditing:[[UITextView alloc] init]];

    XCTAssertNil(commentControllerMock.navigationItem.rightBarButtonItem);
}





- (void)testSetupKeyboardBehaviour {
    commentControllerMock.makeComment = YES;

    [commentControllerMock setupKeyboardBehaviour];

    // XCTAssertTrue(commentControllerMock.is);
}

@end
