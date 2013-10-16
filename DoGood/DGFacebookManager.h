@interface DGFacebookManager : NSObject {
    NSDictionary *postOptions;

    NSError *checkSettingsError;
    NSError *unableToPostError;
    NSError *noAccountError;
}

- (void)checkFacebookPostAccessWithSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *checkError))failure;
- (void)promptForPostAccess;
- (void)postToFacebook:(NSString *)status andImage:(UIImage *)image withSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *postError))failure;
- (void)findFacebookFriendsWithSuccess:(void (^)(NSArray *friends))success failure:(void (^)(NSError *findError))failure;

@end
