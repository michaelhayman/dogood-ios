#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CommentCell.h"
#import "DGComment.h"
#import <TTTAttributedLabel.h>
#import "DGUser.h"

@interface DGCommentCellTests : XCTestCase {
    CommentCell *cell;
    CommentCell *cellMock;
}

@end

// static NSString * const kCommentCell = @"CommentCell";

@implementation DGCommentCellTests

- (void)setUp {
    [super setUp];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UITableViewController *controller = [[UITableViewController alloc] init];
    UINib *nib = [UINib nibWithNibName:kCommentCell bundle:nil];
    [controller.tableView registerNib:nib forCellReuseIdentifier:kCommentCell];

    cell = (CommentCell *)[controller tableView:controller.tableView cellForRowAtIndexPath:indexPath];
    cell = (CommentCell *)[controller.tableView dequeueReusableCellWithIdentifier:kCommentCell];
    cellMock = OCMPartialMock(cell);
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCellValues {
    [cell setValues];

    NSString *commentBody = [NSString stringWithFormat:@"%@ %@", cell.comment.user.full_name, cell.comment.comment];
    XCTAssertEqualObjects(cell.commentBody.text, commentBody);
}

- (void)setupComment {
    DGComment *comment = [[DGComment alloc] init];
    comment.comment = @"Foo";
    comment.user = [[DGUser alloc] init];
    comment.user.full_name = @"Bee";
    cell.comment = comment;
}

@end
