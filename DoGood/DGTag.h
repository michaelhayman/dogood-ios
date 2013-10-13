@interface DGTag : NSObject

@property (retain) NSString *tagID;
@property (retain) NSString *name;

- (NSString *)hashifiedName;

@end
