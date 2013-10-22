#import <XCTest/XCTest.h>
#import "DGComment.h"
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

@end
