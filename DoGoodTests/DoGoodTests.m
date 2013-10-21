#import <XCTest/XCTest.h>
#import "DGGood.h"
#import "DGCategory.h"
#import "DGUser.h"

@interface DGGoodTests : XCTestCase {
    DGGood *good;
}

@end

@implementation DGGoodTests

- (void)setUp {
    [super setUp];
    good = [[DGGood alloc] init];
    good.caption = @"Hey";
    good.goodID = [NSNumber numberWithInt:1];
    good.evidence = @"http://images.dogood.com";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGoodExists {
    XCTAssertNotNil(good, @"good must exist");
}

- (void)testGoodHasACaption {
    XCTAssertEqual(good.caption, @"Hey", @"caption must be set");
}

- (void)testGoodHasAnID {
    XCTAssertEqual(good.goodID, [NSNumber numberWithInt:1], @"good ID must be set");
}

- (void)testGoodHasEvidence {
    NSURL *url = [NSURL URLWithString:good.evidence];
    XCTAssertEqualObjects([url absoluteString],
                          @"http://images.dogood.com",
                         @"The Good's evidence should be represented by a URL");
}

- (void)testGoodHasACategory {
    DGCategory *category = [[DGCategory alloc] init];
    good.category = category;
    XCTAssertEqual(good.category, category, @"good must have a category");
}

- (void)testGoodBelongsToAUser {
    DGUser *user = [[DGUser alloc] init];
    good.user = user;
    XCTAssertEqual(good.user, user, @"good must have a user");
}

@end
