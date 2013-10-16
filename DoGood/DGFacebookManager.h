@class ACAccount;
@interface DGFacebookManager : NSObject {
    NSDictionary *postOptions;
}

- (void)findFacebookFriendsWithSuccess:(void (^)(NSArray *msg))success failure:(void (^)(NSString *error))failure;
- (void)checkFacebookPostAccessWithSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSString *error))failure;
- (void)promptForPostAccess;
- (void)postToFacebook:(NSString *)status andImage:(UIImage *)image withSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSString *error))failure;

@end
