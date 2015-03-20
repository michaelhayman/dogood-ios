#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "DGNotifier.h"
#import "DGUser.h"

@interface DGNotifierTests : XCTestCase {
    DGNotifier *notifier;
}

@end

@implementation DGNotifierTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

/*
- (void)testStart {

    id mockUser = [OCMockObject niceMockForClass:[DGUser class]];
    [[[mockUser stub] andReturn:mockUser] currentUser];
    [[[mockUser stub] andReturnValue:OCMOCK_VALUE(YES)] isSignedIn];

    UITableViewCell *cell = [self authenticateCell];

    XCTAssertEqualObjects(@"My Account", cell.textLabel.text);

    [mockUser stopMocking];
    [[DGNotifier sharedManager] start];
    XCTAssert(YES, @"Pass");
}

- (void)testSendFailure {
    XCTAssert(YES, @"Pass");
}
*/

@end
