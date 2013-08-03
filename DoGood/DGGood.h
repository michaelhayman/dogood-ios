@class DGCategory;
@class DGLocation;

@interface DGGood : PFObject <PFSubclassing>

@property (retain) NSString *caption;
@property (retain) DGCategory *category;
@property (retain) PFUser *user;
@property (retain) DGLocation *location;
@property (retain) PFFile *image;
@property (retain) PFGeoPoint *point;
@property BOOL shareDoGood;
@property BOOL shareTwitter;
@property BOOL shareFacebook;

+ (NSString *)parseClassName;

@end
