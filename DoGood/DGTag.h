@interface DGTag : NSObject

@property (retain) NSNumber *tagID;
@property (retain) NSString *name;

- (NSString *)hashifiedName;

@end
