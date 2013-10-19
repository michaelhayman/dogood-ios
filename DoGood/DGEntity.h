@interface DGEntity : NSObject

@property (retain) NSNumber *entityID;
@property (retain) NSNumber *entityable_id;
@property (retain) NSString *entityable_type;
@property (retain) NSString *link;
@property (retain) NSString *link_type;
@property (retain) NSNumber *link_id;
@property (retain) NSArray *range;
@property (retain) NSString *title;

- (NSRange)rangeFromArray;
- (void)setArrayFromRange:(NSRange)range;
- (NSRange)rangeFromArrayWithOffset:(int)offset;

@end
