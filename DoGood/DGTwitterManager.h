@interface DGTwitterManager : NSObject {
    NSDictionary *postOptions;
    NSString *appName;

    NSError *checkSettingsError;
    NSError *unableToPostError;
    NSError *noAccountError;
}

- (void)checkTwitterPostAccessWithSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *error))failure;
- (void)promptForPostAccess;
- (void)postToTwitter:(NSString *)status andImage:(UIImage *)image withSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *postError))failure;
- (void)findTwitterFriendsWithSuccess:(void (^)(NSArray *msg))success failure:(void (^)(NSError *findError))failure;

@end
