@class ACAccount;

@interface DGFacebookManager : NSObject {
    NSDictionary *postOptions;
    NSString *appName;

    NSError *checkSettingsError;
    NSError *unableToPostError;
    NSError *noAccountError;
}

- (id)initWithAppName:(NSString *)name;
- (void)checkFacebookPostAccessWithSuccess:(void (^)(BOOL success, NSString *msg))success failure:(void (^)(NSError *checkError))failure;
- (void)promptForPostAccess;
- (void)postToFacebook:(NSMutableDictionary *)params andImage:(UIImage *)image withSuccess:(void (^)(BOOL success, NSString *msg, ACAccount *account))success failure:(void (^)(NSError *postError))failure;
- (void)findFacebookFriendsWithSuccess:(void (^)(BOOL success, NSArray *msg, ACAccount *account))success failure:(void (^)(NSError *findError))failure;
- (void)findFacebookIDForAccount:(ACAccount *)account withSuccess:(void (^)(BOOL success, NSString *facebookID))success failure:(void (^)(NSError *findError))failure;

@end
