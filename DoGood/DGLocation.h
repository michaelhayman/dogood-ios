@interface DGLocation : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *displayName;
@property (retain) PFGeoPoint *point;
@property (retain) NSString *fourSquareID;
@property (retain) NSString *category;
@property (retain) NSString *imageURL;

@end