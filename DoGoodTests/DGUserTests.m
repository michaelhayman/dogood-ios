#import <XCTest/XCTest.h>
#import "DGUser.h"

@interface DGUserTests : XCTestCase {
    DGUser *newUser;
}

@end

// static DGUser* existingUser = nil;

@implementation DGUserTests

/*
+ (void)setUp {
    [super setUp];
    existingUser = [DGUser currentUser];
    NSLog(@"setup %@", existingUser.email);
}

+ (void)tearDown {
    [super tearDown];
    [DGUser setCurrentUser:existingUser];
    NSLog(@"tear down %@", [DGUser currentUser].email);
}
*/

- (void)setUp {
    [super setUp];
    newUser = [[DGUser alloc] init];
    newUser.full_name = @"Michael Hayman";
    newUser.email = @"mike@springbox.ca";
    newUser.password = @"sn00shie";
    newUser.biography = @"Makes apps";
    newUser.location = @"Toronto";
    newUser.phone = @"416 365-7308";
    newUser.twitter_id = @"230840283408234";
    newUser.facebook_id = @"108108081081";
    newUser.points = [NSNumber numberWithInt:10000];
    newUser.userID = [NSNumber numberWithInt:10808];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testUserExists {
    DGUser *anotherUser = [[DGUser alloc] init];
    XCTAssertNotNil(anotherUser, @"should be able to create a User instance");
}

- (void)testUserIsNilByDefault {
    DGUser *anotherUser = [[DGUser alloc] init];
    XCTAssertNil(anotherUser.full_name, @"Name should be nil on startup.");
}

- (void)testUserHasAFullName {
    XCTAssertEqual(@"Michael Hayman", newUser.full_name, @"Attributes should get set");
}

- (void)testUserHasAnEmailAddress {
    XCTAssertEqual(@"mike@springbox.ca", newUser.email, @"Set email");
}

- (void)testUserHasABiography {
    XCTAssertEqual(@"Makes apps", newUser.biography, @"Set biography");
}

- (void)testUserHasALocation {
    XCTAssertEqual(@"Toronto", newUser.location, @"User must have a location");
}

- (void)testUserHasATwitterID {
    XCTAssertEqualObjects(@"230840283408234", newUser.twitter_id, @"User must have a twitter ID");
}

- (void)testUserHasAFacebookID {
    XCTAssertEqualObjects(@"108108081081", newUser.facebook_id, @"User must have a facebook ID");
}

- (void)testUserHasAPhoneNumber {
    XCTAssertEqualObjects(@"416 365-7308", newUser.phone, @"User must have a phone number");
}

- (void)testUserHasPoints {
    XCTAssertEqualObjects([NSNumber numberWithInt:10000], newUser.points, @"User must have points");
}

- (void)testUserHasAnID {
    XCTAssertEqualObjects([NSNumber numberWithInt:10808], newUser.userID, @"User must have an ID");
}

- (void)testUserSignIn {
    XCTAssertTrue([newUser isSignedIn], @"user should be signed in");
}

// can't do this since it screws with the actual app testing
/*
- (void)testUserSignOut {
    [newUser signOutWithMessage:NO];
    XCTAssertFalse([newUser isSignedIn], @"user should be signed out");
}
*/
@end
