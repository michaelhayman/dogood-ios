#import <XCTest/XCTest.h>
#import "DGError.h"

@interface DGErrorTests : XCTestCase {
    DGError *error;
}

@end

@implementation DGErrorTests

- (void)setUp {
    [super setUp];
    error = [[DGError alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    NSString *message = @"An error occurred.";
    NSString *message2 = @"It really did.";

    error.messages = [[NSArray alloc] initWithObjects:message, message2, nil];

    XCTAssertEqualObjects(error.description, [error.messages componentsJoinedByString:@"\n"], @"the description should join the error messages together");
}

@end

