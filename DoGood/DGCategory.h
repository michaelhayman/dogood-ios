@interface DGCategory : NSObject

@property (retain) NSNumber *categoryID;
@property (retain) NSString *name;
@property (retain) NSString *name_constant;
@property (retain) NSString *image_url;

- (UIImage *)image;

@end