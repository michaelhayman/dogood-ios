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

typedef void (^RetrieveCommentsBlock)(NSArray *comments, NSError *error);
+ (void)getCommentsForGood:(DGGood *)good page:(NSInteger)page completion:(RetrieveCommentsBlock)completion;

typedef void (^ManageCommentBlock)(DGComment *comment, NSError *error);
+ (void)postComment:(DGComment *)comment completion:(ManageCommentBlock)completion;

@end
