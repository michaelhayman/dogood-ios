#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
@import UIKit;
#import "DGViewController.h"
#import "DGGood.h"
#import "constants.h"
#import "DGGoodCommentsViewController.h"
#import "CommentCell.h"
#import "NoResultsCell.h"

#pragma mark - Category interface (to test private methods)

@interface DGGoodCommentsViewController (Tests)

// Comment management
- (void)getComments;
- (void)reloadComments;
- (void)authenticate;
- (void)addComment:(DGComment *)comment;
- (void)loadMoreComments;
- (void)resetComments;
- (void)setupInfiniteScroll;
- (IBAction)postComment:(id)sender;
- (void)setCommentFieldBottomToDefault;
- (CGFloat)commentInputFieldWidth;

// UITextView
- (void)resetTextView;
- (void)closeComments;
- (void)setTextViewHeight;

// UIKeyboard
- (void)setupKeyboardBehaviour;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)keyboardWillShow:(NSNotification *)notification;

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

#pragma mark - UIViewController tests

- (void)testViewDidLoad {
    [commentControllerMock viewDidLoad];

    XCTAssertFalse([commentControllerMock.sendButton isEnabled]);
    XCTAssertEqual(120, commentControllerMock.characterLimit);
    XCTAssertTrue(CGAffineTransformEqualToTransform(commentControllerMock.tableView.transform, CGAffineTransformMakeRotation(-M_PI)));

    OCMVerify([commentControllerMock setupInfiniteScroll]);
    OCMVerify([commentControllerMock reloadComments]);
}

- (void)testViewDidAppear {
    [commentControllerMock viewDidAppear:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSilentAuthenticationNotification object:nil];
    OCMVerify([commentControllerMock authenticate]);
}

- (void)testViewWillAppear {
    OCMExpect([commentControllerMock setupKeyboardBehaviour]);

    [commentControllerMock viewWillAppear:YES];

    OCMVerify([commentControllerMock setupKeyboardBehaviour]);
}

- (void)testViewWillDisappear {
    [commentControllerMock loadView];

    [commentControllerMock viewWillDisappear:YES];

    XCTAssertTrue(CGAffineTransformEqualToTransform(commentControllerMock.tableView.transform, CGAffineTransformMakeRotation(-M_PI)));
    XCTAssertNil(commentControllerMock.entityHandler);
}

// TODO: figure out how to test that observers are removed (other than sending a message and having no response)
- (void)skipTestViewDidDisappear {
    [commentControllerMock viewDidDisappear:YES];
}

#pragma mark - Comment management tests

- (void)testAddComment {
    commentControllerMock.comments = [[NSMutableArray alloc] init];

    DGComment *comment = [[DGComment alloc] init];
    [commentControllerMock addComment:comment];

    XCTAssertEqualObjects(comment, [commentControllerMock.comments firstObject]);
}

- (void)testLoadMoreComments {
    commentControllerMock.page = 5;

    [commentControllerMock loadMoreComments];

    XCTAssertEqual(commentControllerMock.page, 6);
    OCMVerify([commentControllerMock getComments]);
}

- (void)testGetComments {

    id commentMock = OCMClassMock([DGComment class]);
    DGGood *good = [[DGGood alloc] init];
    [[commentMock stub] getCommentsForGood:good page:1 completion:[OCMArg any]];

    [commentControllerMock getComments];

    OCMVerify([DGComment getCommentsForGood:good page:1 completion:[OCMArg any]]);
}

- (void)testReloadComments {
    [commentControllerMock loadView];

    [commentControllerMock reloadComments];

    // assert loading view

    OCMVerify([commentControllerMock resetComments]);
    OCMVerify([commentControllerMock getComments]);
}

- (void)testResetComments {
    [self setupComments];

    XCTAssertEqual(1, [commentControllerMock.comments count]);

    [commentControllerMock resetComments];

    XCTAssertEqual(0, [commentControllerMock.comments count]);
}

- (void)testPostComment {
    [commentControllerMock loadView];

    commentControllerMock.sendButton.enabled = YES;

    [commentControllerMock postComment:nil];
    XCTAssertFalse([commentControllerMock.sendButton isEnabled]);
}

- (void)testCommentFieldInputWidth {
    [self loadView];

    CGFloat expectedWidth;
    if (iPad) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            expectedWidth = 704;
        } else {
            expectedWidth = 960;
        }
    } else {
        expectedWidth = 240;
    }
    XCTAssertEqual(expectedWidth, [commentControllerMock commentInputFieldWidth]);
}

#pragma mark - UITableView tests

- (void)testCellForRowAtIndexPathAssignsNoResultsCorrectly {
    [self loadView];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    NoResultsCell * cell = (NoResultsCell *)[commentControllerMock tableView:commentControllerMock.tableView cellForRowAtIndexPath:indexPath];
    XCTAssertEqualObjects([NoResultsCell class], [cell class]);
}

- (void)testCellForRowAtIndexPathAssignsCommentCorrectly {
    [self loadView];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self setupComments];

    CommentCell * cell = (CommentCell *)[commentControllerMock tableView:commentControllerMock.tableView cellForRowAtIndexPath:indexPath];
    XCTAssertEqualObjects(cell.comment, [commentControllerMock.comments firstObject]);
}

- (void)testHeightForRowAtIndexPathWhenEmpty {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    XCTAssertEqual(150, [commentControllerMock tableView:commentControllerMock.tableView heightForRowAtIndexPath:indexPath]);
}

- (void)testHeightForRowAtIndexPathCommentsExist {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self setupComments];

    XCTAssertEqual(63, [commentControllerMock tableView:commentControllerMock.tableView heightForRowAtIndexPath:indexPath]);
}

- (void)testNumberOfRowsInSectionWhenEmpty {
    XCTAssertEqual(1, [commentControllerMock tableView:commentControllerMock.tableView numberOfRowsInSection:0]);
}

- (void)testNumberOfRowsInSectionWhenCommentsExist {
    [self setupComments];

    DGComment *comment2 = [[DGComment alloc] init];
    comment2.comment = @"Hey";
    [commentControllerMock.comments addObject:comment2];

    XCTAssertEqual(2, [commentControllerMock tableView:commentControllerMock.tableView numberOfRowsInSection:0]);
}

- (void)testSectionsInTableView {
    XCTAssertEqual(1, [commentControllerMock numberOfSectionsInTableView:commentControllerMock.tableView]);
}

#pragma mark - UIKeyboard tests

- (void)testKeyboardWillShow {
    commentControllerMock.makeComment = YES;

    [self loadView];
    [commentControllerMock keyboardWillShow:nil];

    XCTAssertFalse(commentControllerMock.makeComment);
}

- (void)testKeyboardWillHide {
    [self loadView];
    [commentControllerMock keyboardWillHide:nil];

    XCTAssertEqual(49, commentControllerMock.commentFieldBottom.constant);
}

- (void)testCommentFieldBottomDefault {
    [self loadView];
    [controller setCommentFieldBottomToDefault];

    XCTAssertEqual(49, commentControllerMock.commentFieldBottom.constant);
}

- (void)testSetupKeyboardBehaviourShowNotification {
    [commentControllerMock loadView];
    [commentControllerMock setupKeyboardBehaviour];

    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillShowNotification object:nil];
    OCMVerify([commentControllerMock keyboardWillShow:[OCMArg any]]);
}

- (void)testSetupKeyboardBehaviourHideNotification {
    [commentControllerMock loadView];
    [commentControllerMock setupKeyboardBehaviour];

    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:nil];
    OCMVerify([commentControllerMock keyboardWillHide:[OCMArg any]]);
}

#pragma mark - UITextView tests

- (void)testTextViewDidBeginEditing {
    [commentControllerMock textViewDidBeginEditing:[[UITextView alloc] init]];

    XCTAssertNotNil(commentControllerMock.navigationItem.rightBarButtonItem);
}

- (void)testTextViewDidEndEditing {
    [commentControllerMock textViewDidEndEditing:[[UITextView alloc] init]];

    XCTAssertNil(commentControllerMock.navigationItem.rightBarButtonItem);
}

- (void)testTextViewShouldntChangeTextInRangeIfEqualToOrOverCharacterLimit {
    NSString *string;
    UITextView *textView;
    NSRange range;

    [self loadView];
    range = NSMakeRange(commentControllerMock.characterLimit, 1);
    BOOL shouldReturn = [commentControllerMock textView:textView shouldChangeTextInRange:range replacementText:string];

    XCTAssertFalse(shouldReturn);
}

- (void)testTextViewShouldntChangeTextInRangeIfEnterKeyPressed {
    NSString *string;
    UITextView *textView;
    NSRange range;

    [self loadView];
    range = NSMakeRange(commentControllerMock.characterLimit - 10, 1);
    string = @"\n";
    BOOL shouldReturn = [commentControllerMock textView:textView shouldChangeTextInRange:range replacementText:string];

    XCTAssertFalse(shouldReturn);
}

- (void)testTextViewShouldChangeTextInRange {
    // given
    NSString *string;
    UITextView *textView = [[UITextView alloc] init];
    NSRange range;

    // when
    [self loadView];
    string = @"sup";
    range = NSMakeRange(commentControllerMock.characterLimit - 10, [string length]);
    commentControllerMock.commentInputField.text = @"hi";
    BOOL shouldReturn = [commentControllerMock textView:textView shouldChangeTextInRange:range replacementText:string];

    // then
    XCTAssertTrue(shouldReturn);
    XCTAssertTrue([commentControllerMock.sendButton isEnabled]);
}

- (void)testTextViewHeight {
    [self loadView];

    [commentControllerMock setTextViewHeight];

    XCTAssertEqual(30, commentControllerMock.commentInputFieldHeight.constant);
}

- (void)testResetTextView {
    [self loadView];

    [commentControllerMock resetTextView];
    XCTAssertEqual(30.0, commentControllerMock.commentInputFieldHeight.constant);
}

- (void)testTextViewDidChange {
    [self loadView];

    UITextView *textView = [[UITextView alloc] init];
    textView.text = @"Comment";
    [commentControllerMock textViewDidChange:textView];
    XCTAssertTrue([commentControllerMock.sendButton isEnabled]);
    textView.text = @"Comment which is way too long to be allowed under the character limit and this is way too long still I don't know how many more characters I can possibly type to illustrate my point but I will keep going until it is enough.";
    [commentControllerMock textViewDidChange:textView];
    XCTAssertFalse([commentControllerMock.sendButton isEnabled]);
}

- (void)testCloseComments {
    [self loadView];

    [commentControllerMock.commentInputField becomeFirstResponder];

    [commentControllerMock closeComments];

    XCTAssertFalse([commentControllerMock.commentInputField isFirstResponder]);
}

#pragma mark - Helper methods

- (void)loadView {
    [commentControllerMock viewDidLoad];
}

- (void)setupComments {
    DGComment *comment = [[DGComment alloc] init];
    comment.comment = @"Hey";
    commentControllerMock.comments = [[NSMutableArray alloc] initWithObjects:comment, nil];
}

@end
