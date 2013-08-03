@interface DGCategory : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *displayName;

@end