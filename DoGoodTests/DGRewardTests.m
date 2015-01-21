#import <XCTest/XCTest.h>
#import "DGReward.h"

@interface DGRewardTests : XCTestCase {
    DGReward *reward;
}

@end

@implementation DGRewardTests

- (void)setUp {
    [super setUp];
    reward = [[DGReward alloc] init];
}

- (void)tearDown {
    [super tearDown];
    reward = nil;
}

- (void)testRewardText {
    reward.cost = [NSNumber numberWithInteger:56];
    XCTAssertEqualObjects([reward costText], @"56 points", @"the amount of good should be set in readable text");
}

@end
