@class DGGood;
@class DGUser;

@interface DGComment : NSObject

@property (retain) NSString *comment;
@property (retain) NSString *commentable_type;
@property (retain) NSNumber *commentable_id;
@property (retain) NSNumber *user_id;
@property (retain) DGGood *good;
@property (retain) DGUser *user;
@property (retain) NSArray *entities;
@property (retain) NSDate *created_at;

- (NSString *)createdAgoInWords;
- (NSString *)commentWithUsername;
- (CGFloat)commentBoxWidth;

@end
