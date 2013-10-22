#import <XCTest/XCTest.h>
#import "URLHandler.h"

@interface DGURLHandlerTests : XCTestCase {
    URLHandler *handler;
}

@end

@implementation DGURLHandlerTests

- (void)setUp {
    [super setUp];
    handler = [[URLHandler alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCanRejectIncorrectURLs {
    NSURL *url = [NSURL URLWithString:@"doegood://goods/5"];
    [handler openURL:url andReturn:^(BOOL matched) {
        XCTAssertFalse(matched, @"it should not match the URL");
        return matched;
    }];
}

- (void)testCanHandleGoods {
    NSURL *url = [NSURL URLWithString:@"dogood://goods/5"];
    [handler openURL:url andReturn:^(BOOL matched) {
        XCTAssertTrue(matched, @"it should match the URL");
        return matched;
    }];
}

- (void)testCanHandleTaggedGoods {
    NSURL *url = [NSURL URLWithString:@"dogood://goods/tagged/5"];
    [handler openURL:url andReturn:^(BOOL matched) {
        XCTAssertTrue(matched, @"it should match the URL");
        return matched;
    }];
}

- (void)testCanHandleUsers {
    NSURL *url = [NSURL URLWithString:@"dogood://users/5"];
    [handler openURL:url andReturn:^(BOOL matched) {
        XCTAssertTrue(matched, @"it should match the URL");
        return matched;
    }];
}

@end

