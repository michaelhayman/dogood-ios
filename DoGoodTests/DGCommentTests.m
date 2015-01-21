#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "DGComment.h"
#import "DGGood.h"
#import "DGUser.h"
#import <NSDate+TimeAgo.h>

@interface DGCommentTests : XCTestCase {
    DGComment * comment;
}

@end

@implementation DGCommentTests

- (void)setUp {
    [super setUp];
    comment = [[DGComment alloc] init];
    comment.user = [[DGUser alloc] init];
    comment.user.full_name = @"Michael Hayman";
    comment.comment = @"I like doing unit tests";
}

- (void)tearDown {
    [super tearDown];
    comment = nil;
}

- (void)testCreation {
    comment.created_at = [NSDate distantPast];
    NSString *timeAgo = [comment.created_at timeAgo];
    XCTAssertEqualObjects(comment.createdAgoInWords, timeAgo, @"comment should have a nice timestamp");
}

- (void)testCommentWithUsername {
    NSString *commentAndUsername = @"Michael Hayman I like doing unit tests";
    XCTAssertEqualObjects([comment commentWithUsername], commentAndUsername, @"comment with username");
}

- (void)testPostCommentFailsIfNotSignedIn {
    DGGood *good = [[DGGood alloc] init];
    good.goodID = [NSNumber numberWithInt:1];

    XCTestExpectation *exp = [self expectationWithDescription:@"Post Comment"];

    [DGComment postComment:comment completion:^(DGComment *postedComment, NSError *error) {
        XCTAssertNotNil(error);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        NSLog(@"finished");
    }];
}

- (void)testPostCommentSucceeds {
    DGGood *good = [[DGGood alloc] init];
    good.goodID = [NSNumber numberWithInt:1];

    NSString *commentBody = @"I like comments";

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSDictionary* obj = @{ @"comments": @[ @{ @"comment": commentBody } ] };
        return [OHHTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];

    XCTestExpectation *exp = [self expectationWithDescription:@"Post Comment"];

    [DGComment postComment:comment completion:^(DGComment *postedComment, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqualObjects(postedComment.comment, commentBody);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        NSLog(@"finished");
    }];
}

- (void)testGetComments {
    DGGood *good = [[DGGood alloc] init];
    good.goodID = [NSNumber numberWithInt:1];

    NSString *commentBody = @"I like comments";

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSDictionary* obj = @{ @"comments": @[ @{ @"comment": commentBody } ] };
        return [OHHTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];

    XCTestExpectation *exp = [self expectationWithDescription:@"Post Comment"];

    [DGComment getCommentsForGood:good page:1 completion:^(NSArray *comments, NSError *error) {
        XCTAssertNil(error);
        DGComment *firstComment = [comments firstObject];
        XCTAssertEqualObjects(firstComment.comment, commentBody);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        NSLog(@"finished");
    }];
}

@end
