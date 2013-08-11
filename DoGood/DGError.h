@interface DGError : NSObject

@property (nonatomic, copy) NSString* code;
@property (nonatomic, copy) NSArray* messages;

@end