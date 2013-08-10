@class DGCategory;
@class DGUser;
@class DGLocation;

@interface DGGood : NSObject

@property (retain) NSString *caption;
@property (retain) DGCategory *category;
@property (retain) DGUser *user;
@property (retain) DGLocation *location;
@property (retain) UIImage *image;
@property (retain) NSArray *point;
@property (retain) NSNumber *current_user_liked;
@property BOOL shareDoGood;
@property BOOL shareTwitter;
@property BOOL shareFacebook;

@end
