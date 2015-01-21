#import <XCTest/XCTest.h>
#import "DGEntityHandler.h"
#import "DGEntity.h"

@interface DGEntityHandlerTests : XCTestCase {
    DGEntityHandler *entityHandler;
    NSMutableArray *entities;
    UITextView *textView;
}

@end

@implementation DGEntityHandlerTests

- (void)setUp
{
    [super setUp];
    entities = [[NSMutableArray alloc] init];

    DGEntity *entity = [[DGEntity alloc] init];
    entity.range = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:6], nil];
    [entities addObject:entity];

    UIViewController *mockView = [[UIViewController alloc] init];

    textView = [[UITextView alloc] init];
    textView.text = @"Michael Hayman is a guy who likes to program";
    entityHandler = [[DGEntityHandler alloc] initWithTextView:textView andEntities:entities inController:mockView withType:@"notsure" reverseScroll:YES tableOffset:5 secondTableOffset:6];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNoMatch {
    NSRange range = NSMakeRange(1, 3);
    BOOL sup = [entityHandler check:textView range:range forEntities:entities completion:^BOOL(BOOL end, NSMutableArray *entities) {
        XCTAssertTrue(end, @"stop editing and to highlight entity");
    }];
    XCTAssertTrue(sup, @"should return that we can change the text");
}

- (void)testDeleteRange {
    NSRange range = NSMakeRange(5, 1);
    BOOL sup = [entityHandler check:textView range:range forEntities:entities completion:^BOOL(BOOL end, NSMutableArray *theseEntities) {
        XCTAssertTrue(end, @"allow editing and delete entity");
        NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
        XCTAssertEqualObjects(theseEntities, emptyArray, @"objects should be empty");
    }];
    XCTAssertTrue(sup, @"textfield should be allowed deletion");
}

- (void)testSelectMatchedRange {
    NSRange range = NSMakeRange(5, 10);
    BOOL sup = [entityHandler check:textView range:range forEntities:entities completion:^BOOL(BOOL end, NSMutableArray *entities) {
        XCTAssertTrue(end, @"stop editing and highlight entity");
    }];
    XCTAssertFalse(sup, @"stop editing");
}

@end
