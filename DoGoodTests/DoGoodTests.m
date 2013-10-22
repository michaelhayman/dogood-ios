#import <XCTest/XCTest.h>
#import "DGGood.h"
#import "DGCategory.h"
#import "DGUser.h"
#import "DGComment.h"
#import "DGEntity.h"
#import "FSLocation.h"

@interface DGGoodTests : XCTestCase {
    DGGood *good;
    NSNumber *lat;
    NSNumber *lng;
    NSString *imageURL;
}

@end

@implementation DGGoodTests

- (void)setUp {
    [super setUp];
    lat = [NSNumber numberWithDouble:-74.370280];
    lng = [NSNumber numberWithDouble:47.370280];
    imageURL = @"http://www.images.com/image.jpg";

    good = [[DGGood alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGoodExists {
    XCTAssertNotNil(good, @"good must exist");
}

- (void)testGoodHasACaption {
    good.caption = @"Hey";
    XCTAssertEqual(good.caption, @"Hey", @"caption must be set");
}

- (void)testGoodHasAnID {
    good.goodID = [NSNumber numberWithInt:1];
    XCTAssertEqual(good.goodID, [NSNumber numberWithInt:1], @"good ID must be set");
}

- (void)testGoodHasEvidence {
    good.evidence = imageURL;
    NSURL *url = [NSURL URLWithString:good.evidence];
    XCTAssertEqualObjects([url absoluteString],
                          imageURL,
                         @"The Good's evidence should be represented by a URL");
}

- (void)testGoodHasACategory {
    DGCategory *category = [[DGCategory alloc] init];
    good.category = category;
    XCTAssertEqual(good.category, category, @"good must have a category");
}

- (void)testGoodCanSetCategory {
    DGCategory *category = [[DGCategory alloc] init];
    NSNumber *identifier = [NSNumber numberWithInt:56];
    category.categoryID = identifier;
    [good setValuesForCategory:category];
    XCTAssertEqual(good.category_id, category.categoryID, @"good must have a category");
}

- (void)testGoodCanBeMarkedDone {
    NSNumber *done = [NSNumber numberWithBool:YES];
    good.done = done;
    XCTAssertEqual(good.done, done, @"good must be able to be complete");
}

- (void)testGoodBelongsToAUser {
    DGUser *user = [[DGUser alloc] init];
    good.user = user;
    XCTAssertEqual(good.user, user, @"good must have a user");
}

- (void)testGoodHasComments {
    DGComment *comment = [[DGComment alloc] init];
    good.comments = [[NSArray alloc] initWithObjects:comment, nil];
    XCTAssertEqual([good.comments objectAtIndex:0], comment, @"good must have comments");
}

- (void)testGoodCanSetLocation {
    FSLocation *location = [[FSLocation alloc] init];
    location.displayName = @"Starbucks";
    location.lat = lat;
    location.lng = lng;
    location.imageURL = imageURL;
    [good setValuesForLocation:location];

    XCTAssertEqual(good.location_image, location.imageURL, @"good must have location image set");
    XCTAssertEqual(good.lat, location.lat, @"good must have latitude set");
    XCTAssertEqual(good.lng, location.lng, @"good must have longitude set");
    XCTAssertEqual(good.location_name, location.displayName, @"good must have location name set");
}

- (void)testGoodHasACoordinate {
    good.lat = lat;
    good.lng = lng;

    XCTAssertEqual(good.lat, lat, @"good must have a latitude");
    XCTAssertEqual(good.lng, lng, @"good must have a longitude");
}

- (void)testGoodHasALocationName {
    NSString *location = @"Arby's";
    good.location_name = location;
    XCTAssertEqual(good.location_name, location, @"good must have a location");
}

- (void)testGoodIsShareable {
    good.shareDoGood = YES;
    good.shareFacebook = YES;
    good.shareTwitter = YES;

    XCTAssertTrue(good.shareDoGood, @"good is shareable on Do Good");
    XCTAssertTrue(good.shareFacebook, @"good is shareable on Facebook");
    XCTAssertTrue(good.shareTwitter, @"good is shareable on Twitter");
}

- (void)testCurrentUserStatusOnGood {
    good.current_user_commented = [NSNumber numberWithBool:YES];
    good.current_user_liked = [NSNumber numberWithBool:YES];
    good.current_user_regooded = [NSNumber numberWithBool:YES];

    XCTAssertEqual(good.current_user_commented, [NSNumber numberWithBool:YES], @"user commented on good");
    XCTAssertEqual(good.current_user_liked, [NSNumber numberWithBool:YES], @"user liked good");
    XCTAssertEqual(good.current_user_regooded, [NSNumber numberWithBool:YES], @"user regooded good");
}

- (void)testGoodHasStatus {
    NSNumber *regoods = [NSNumber numberWithInt:56];
    NSNumber *likes = [NSNumber numberWithInt:57];
    NSNumber *comments = [NSNumber numberWithInt:50000];
    good.regoods_count = regoods;
    good.likes_count = likes;
    good.comments_count = comments;

    XCTAssertEqual(good.regoods_count, regoods, @"user regooded good");
    XCTAssertEqual(good.likes_count, likes, @"user liked good");
    XCTAssertEqual(good.comments_count, comments, @"user commented on good");
}

- (void)testGoodHasEntities {
    DGEntity *entity = [[DGEntity alloc] init];
    good.entities = [[NSArray alloc] initWithObjects:entity, nil];
    XCTAssertEqual([good.entities objectAtIndex:0], entity, @"good must have entities");
}

- (void)testGoodCanHaveAnImage {
    UIImage * image = [UIImage imageNamed:@"sup"];
    good.image = image;
    XCTAssertEqual(good.image, image, @"good can have an image set");
}

@end
