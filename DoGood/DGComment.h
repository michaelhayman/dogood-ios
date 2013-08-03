@class DGGood;

@interface DGComment : PFObject <PFSubclassing>

@property (retain) NSString *body;
@property (retain) DGGood *good;
@property (retain) PFUser *user;

+ (NSString *)parseClassName;

@end
