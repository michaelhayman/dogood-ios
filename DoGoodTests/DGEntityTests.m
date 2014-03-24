#import <XCTest/XCTest.h>
#import "DGEntity.h"

@interface DGEntityTests : XCTestCase {
    DGEntity *entity;
    int start;
    int end;
    NSArray *arrayRange;
}

@end

@implementation DGEntityTests

- (void)setUp {
    [super setUp];
    entity = [[DGEntity alloc] init];
    start = 5;
    end = 17;
    arrayRange = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:start], [NSNumber numberWithInt:end], nil];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRangeFromArray {
    NSRange range = NSMakeRange(start, end - start);
    entity.range = arrayRange;
    // XCTAssertEqual(range, [entity rangeFromArray], @"NSRange should be properly converted from server-side range");
}

- (void)testRangeFromArrayWithOffsets {
    int offset = 3;
    NSRange range = NSMakeRange(start + offset, end - start);
    entity.range = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:start], [NSNumber numberWithInt:end], nil];
    // XCTAssertEqual(range, [entity rangeFromArrayWithOffset:offset], @"NSRange should be properly converted from server-side range");
}

- (void)testRangeToArray {
    [entity setRange:arrayRange];
    XCTAssertEqual(entity.range, arrayRange, @"NSRange should be properly converted from server-side range");
}

@end
