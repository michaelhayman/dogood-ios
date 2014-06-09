@interface DGEntity : NSObject

@property (retain) NSNumber *entityID;
@property (retain) NSString *link;
@property (retain) NSString *link_type;
@property (retain) NSNumber *link_id;
@property (retain) NSArray *range;
@property (retain) NSString *title;

- (NSRange)rangeFromArray;
- (void)setArrayFromRange:(NSRange)range;
- (NSRange)rangeFromArrayWithOffset:(NSInteger)offset;

typedef void (^HashSearchCompletionBlock)(NSArray *entities, NSError *error);
+ (void)findTagEntitiesIn:(NSString *)string forLinkID:(NSNumber *)linkID completion:(HashSearchCompletionBlock)completion;

@end
