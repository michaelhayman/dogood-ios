#import <XCTest/XCTest.h>
#import "DGTag.h"

@interface DGTagTests : XCTestCase {
    DGTag *tag;
}

@end

@implementation DGTagTests

- (void)setUp {
    [super setUp];
    tag = [[DGTag alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testTagHash {
    tag.name = @"puppies";
    XCTAssertEqualObjects([tag hashifiedName], @"puppies", @"name should be hashified");
}

@end
