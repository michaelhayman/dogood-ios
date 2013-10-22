@class DGUser;
@interface DGReward : NSObject

@property (retain) NSNumber *rewardID;
@property (retain) NSString *title;
@property (retain) NSString *subtitle;
@property (retain) NSString *teaser;
@property (retain) NSString *full_description;
@property (retain) NSNumber *cost;
@property (retain) NSNumber *quantity;
@property (retain) NSNumber *quantity_remaining;
@property (retain) NSNumber *user_id;
@property (retain) NSString *instructions;
@property (retain) DGUser *user;

- (NSString *)costText;

@end
