#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "DGLocator.h"

@interface DGLocatorTests : XCTestCase {
    id locationManagerMock;
}

@end

@implementation DGLocatorTests

- (void)setUp {
    [super setUp];
    locationManagerMock = OCMClassMock([CLLocationManager class]);
}

- (void)tearDown {
    [super tearDown];
    [locationManagerMock stopMocking];
}

- (void)testLocationServicesEnabled {
    [[[locationManagerMock stub] andReturnValue:@(kCLAuthorizationStatusAuthorizedWhenInUse)] authorizationStatus];

    [DGLocator checkLocationAccessWithSuccess:^(BOOL success, NSString *msg) {
        XCTAssertNotNil(msg);
        XCTAssertTrue(success);
    } failure:^(NSError *error) {
        XCTAssertNil(error);
    }];

}

- (void)testLocationServicesPermissionDenied {
    [[[locationManagerMock stub] andReturnValue:@(kCLAuthorizationStatusDenied)] authorizationStatus];

    [DGLocator checkLocationAccessWithSuccess:^(BOOL success, NSString *msg) {
        XCTAssertFalse(success);
    } failure:^(NSError *error) {
        XCTAssertNotNil(error);
    }];
}

- (void)testLocationServicesDisabled {
    [[[[locationManagerMock stub] classMethod] andReturnValue:OCMOCK_VALUE(NO)] locationServicesEnabled];

    [DGLocator checkLocationAccessWithSuccess:^(BOOL success, NSString *msg) {
        XCTAssertFalse(success);
    } failure:^(NSError *error) {
        XCTAssertNotNil(error);
    }];
}

@end
