@interface DGCategory : NSObject

@property (retain) NSNumber *categoryID;
@property (retain) NSString *name;
@property (retain) NSString *name_constant;
@property (retain) NSString *colour;
@property (copy) NSString *image_url;

- (UIImage *)image;
- (UIImage *)contentIcon;
- (UIColor *)rgbColour;

@end