#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "NoResultsCell.h"
#import "constants.h"

@interface DGNoResultsCellTests : XCTestCase {
    NoResultsCell *cell;
    NoResultsCell *cellMock;
}

@end

@implementation DGNoResultsCellTests

- (void)setUp {
    [super setUp];
    UITableViewController *controller = [[UITableViewController alloc] init];
    UINib *nib = [UINib nibWithNibName:kNoResultsCell bundle:nil];
    [controller.tableView registerNib:nib forCellReuseIdentifier:kNoResultsCell];

    cell = (NoResultsCell *)[controller.tableView dequeueReusableCellWithIdentifier:kNoResultsCell];
    cellMock = OCMPartialMock(cell);
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetHeadingWithHeadingExplanationAndImage {
    NSString *heading = @"Heading";
    NSString *explanation = @"This is an explanation of how to remedy the emptiness.";
    UIImage *image = [UIImage imageNamed:@"NoComments"];

    [cell setHeading:heading explanation:explanation andImage:image];

    XCTAssertEqual(40, cell.headingHeight.constant);
    XCTAssertEqual(5, cell.headingSpacer.constant);
    XCTAssertEqual(36, cell.explanationHeight.constant);
    XCTAssertEqual(100, cell.imageHeight.constant);
    XCTAssertEqual(10, cell.imageSpacer.constant);
    XCTAssertEqualObjects(heading, cell.heading.text);
    XCTAssertEqualObjects(explanation, cell.explanation.text);
    XCTAssertNotNil(cell.image.image);
}

- (void)testSetHeadingWithNoImage {
    NSString *heading = @"Heading";
    NSString *explanation = @"This is an explanation of how to remedy the emptiness.";
    [cell setHeading:heading andExplanation:explanation];

    XCTAssertEqual(0, cell.imageHeight.constant);
    XCTAssertEqual(0, cell.imageSpacer.constant);
    XCTAssertNil(cell.image.image);
}

- (void)testSetHeadingWithNoHeading {
    NSString *explanation = @"This is an explanation of how to remedy the emptiness.";
    UIImage *image = [UIImage imageNamed:@"NoComments"];

    [cell setHeading:nil explanation:explanation andImage:image];

    XCTAssertEqual(0, cell.headingHeight.constant);
    XCTAssertEqual(0, cell.headingSpacer.constant);
    XCTAssertNil(cell.heading.text);
}

- (void)setHeadingWithNoExplanation {
    NSString *heading = @"Heading";
    UIImage *image = [UIImage imageNamed:@"NoComments"];

    [cell setHeading:heading explanation:nil andImage:image];

    XCTAssertEqual(0, cell.explanationHeight.constant);
    XCTAssertNil(cell.explanation.text);
}

@end
