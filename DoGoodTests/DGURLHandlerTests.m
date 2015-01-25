#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "URLHandler.h"

@interface DGURLHandlerTests : XCTestCase {
    URLHandler *handler;
    id nav;
}

@end

@implementation DGURLHandlerTests

- (void)setUp {
    [super setUp];
    handler = [[URLHandler alloc] init];
    nav = OCMClassMock([UINavigationController class]);
    [[nav stub] pushViewController:[OCMArg isNotNil] animated:[OCMArg any]];
}

- (void)tearDown {
    [super tearDown];
    [nav stopMocking];
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

- (void)testCanHandlePostingNewGoods {
    NSURL *url = [NSURL URLWithString:@"dogood://goods/new"];
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

