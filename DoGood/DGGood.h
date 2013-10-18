@class DGCategory;
@class DGUser;
@class FSLocation;

@interface DGGood : NSObject

@property (retain) NSNumber *goodID;
@property (retain) NSString *caption;
@property (retain) DGCategory *category;
@property (retain) NSString *evidence;
@property (retain) UIImage *image;
// user
@property (retain) DGUser *user;
@property (retain) NSNumber *user_id;
// likes
@property (retain) NSNumber *current_user_liked;
@property (retain) NSNumber *likes_count;
@property (retain) NSNumber *regoods_count;
// comments
@property (retain) NSNumber *current_user_commented;
@property (retain) NSNumber *comments_count;
@property (retain) NSArray *comments;
@property (retain) NSNumber *category_id;
// regoods
@property (retain) NSNumber *current_user_regooded;
// location
@property (retain) NSNumber *lat;
@property (retain) NSNumber *lng;
@property (retain) NSArray *point;
@property (retain) NSString *location_name;
@property (retain) NSString *location_image;
@property (retain) NSNumber *done;
@property BOOL shareDoGood;
@property BOOL shareTwitter;
@property BOOL shareFacebook;
@property (retain) NSArray *entities;

- (void)setValuesForLocation:(FSLocation *)location;
- (void)setValuesForCategory:(DGCategory *)category;

@end
