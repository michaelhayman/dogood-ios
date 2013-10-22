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
    UIViewController *mockView = [[UIViewController alloc] init];
    textView = [[UITextView alloc] init];
    textView.text = @"Michael Hayman is a guy who lkes to program";
    entityHandler = [[DGEntityHandler alloc] initWithTextView:textView andEntities:entities inController:mockView withType:@"notsure" reverseScroll:YES tableOffset:5 secondTableOffset:6];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNoMatch {
    NSRange range = NSMakeRange(5, 5);
    [entityHandler check:textView range:range forEntities:entities completion:^BOOL(BOOL end, NSMutableArray *entities) {
        XCTAssertTrue(end, @"stop editing and to highlight entity");
    }];
}

- (void)testMatch {
    NSRange range = NSMakeRange(5, 10);
    [entityHandler check:textView range:range forEntities:entities completion:^BOOL(BOOL end, NSMutableArray *entities) {
        XCTAssertFalse(end, @"stop editing and to highlight entity");
    }];
}

@end
