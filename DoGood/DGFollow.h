typedef void (^ErrorBlock)(NSError *error);
typedef void (^SuccessBlock)(BOOL success, NSString *msg);

@interface DGFollow : NSObject

+ (void)followType:(NSString *)followableType withID:(NSNumber *)followableID inController:(UINavigationController *)controller withSuccess:(SuccessBlock)success failure:(ErrorBlock)failure;
+ (void)unfollowType:(NSString *)followableType withID:(NSNumber *)followableID inController:(UINavigationController *)controller withSuccess:(SuccessBlock)success failure:(ErrorBlock)failure;

@end
