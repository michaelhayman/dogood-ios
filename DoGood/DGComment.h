@class DGGood;
@class DGUser;

@interface DGComment : NSObject

@property (retain) NSString *body;
@property (retain) DGGood *good;
@property (retain) DGUser *user;

@end
