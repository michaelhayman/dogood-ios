@class DGCategory;
@class DGUser;
@class FSLocation;
@class DGNominee;

@interface DGGood : NSObject

@property (retain) NSNumber *goodID;
@property (retain) NSString *caption;
// image
@property (retain) NSString *evidence;
@property (retain) UIImage *image;
// category
@property (retain) DGCategory *category;
@property (retain) NSNumber *category_id;
// user
@property (retain) DGUser *user;
// nominee
@property (retain) DGNominee *nominee;
// likes
@property (retain) NSNumber *current_user_liked;
@property (retain) NSNumber *likes_count;
@property (retain) NSNumber *regoods_count;
// comments
@property (retain) NSNumber *current_user_commented;
@property (retain) NSNumber *comments_count;
@property (retain) NSArray *comments;
// regoods
@property (retain) NSNumber *current_user_regooded;
// location
@property (retain) NSNumber *lat;
@property (retain) NSNumber *lng;
@property (retain) NSString *location_name;
@property (retain) NSString *location_image;
// share
@property BOOL shareDoGood;
@property BOOL shareTwitter;
@property BOOL shareFacebook;
// entities
@property (retain) NSArray *entities;
// done status
@property (retain) NSNumber *done;
@property (retain) NSDate *created_at;

- (void)setValuesForLocation:(FSLocation *)location;
- (void)setValuesForCategory:(DGCategory *)category;
- (NSString *)createdAgoInWords;
- (NSString *)postedByLine;

@end
