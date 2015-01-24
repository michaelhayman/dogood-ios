#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CommentCell.h"
#import "DGComment.h"
#import <TTTAttributedLabel.h>
#import "DGUser.h"
#import "URLHandler.h"

@interface CommentCell (Tests) <TTTAttributedLabelDelegate>

- (void)showGoodUserProfile;

@end

@interface DGCommentCellTests : XCTestCase {
    CommentCell *cell;
    CommentCell *cellMock;
}

@end

@implementation DGCommentCellTests

- (void)setUp {
    [super setUp];

    UITableViewController *controller = [[UITableViewController alloc] init];
    UINib *nib = [UINib nibWithNibName:kCommentCell bundle:nil];
    [controller.tableView registerNib:nib forCellReuseIdentifier:kCommentCell];

    cell = (CommentCell *)[controller.tableView dequeueReusableCellWithIdentifier:kCommentCell];
    cellMock = OCMPartialMock(cell);
}

- (void)tearDown {
    [super tearDown];
}

- (void)DISABLED_testAttributedLabelDidSelectLinkWithURL {
    id mockHandler = OCMClassMock([URLHandler class]);

    NSURL *url = [NSURL URLWithString:@"/users/5"];

    [[mockHandler expect] openURL:url andReturn:[OCMArg any]];

    [cell attributedLabel:[OCMArg isNotNil] didSelectLinkWithURL:url];

    [[mockHandler verify] openURL:url andReturn:[OCMArg any]];
    [mockHandler stopMocking];
}

- (void)testShowGoodUserProfile {
    id mockUser = OCMClassMock([DGUser class]);

    [[mockUser expect] openProfilePage:[OCMArg any] inController:[OCMArg any]];

    [cell showGoodUserProfile];

    [[mockUser verify] openProfilePage:[OCMArg any] inController:[OCMArg any]];
    [mockUser stopMocking];
}

- (void)testSetSelected {
    [cell setSelected:YES animated:YES];
    XCTAssertEqual(UITableViewCellSelectionStyleNone, cell.selectionStyle);
}

// Also tests awakeFromNib & AddUserNameAndLinksToComment by consequence of the load order
- (void)testCellValues {
    [cell setValues];

    NSString *commentBody = [NSString stringWithFormat:@"%@ %@", cell.comment.user.full_name, cell.comment.comment];
    XCTAssertEqualObjects(cell.commentBody.text, commentBody);
    XCTAssertNil(cell.avatar.image);
    XCTAssertEqual(16, cell.commentBodyHeight.constant);
}

- (void)setupComment {
    DGComment *comment = [[DGComment alloc] init];
    comment.comment = @"Foo";
    comment.user = [[DGUser alloc] init];
    comment.user.full_name = @"Bee";
    cell.comment = comment;
}

@end
