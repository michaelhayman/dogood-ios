@class ACAccount;
@interface DGTwitterManager : NSObject {
    NSDictionary *postOptions;
    NSString *appName;

    NSError *checkSettingsError;
    NSError *unableToPostError;
    NSError *noAccountError;
}

- (void)checkTwitterPostAccessWithSuccess:(void (^)(BOOL success, NSString *msg))success failure:(void (^)(NSError *error))failure;
- (void)promptForPostAccess;
- (void)postToTwitter:(NSString *)status andImage:(UIImage *)image withSuccess:(void (^)(BOOL success, NSString *msg, ACAccount *account))success failure:(void (^)(NSError *postError))failure;
- (void)findTwitterFriendsWithSuccess:(void (^)(BOOL success, NSArray *msg, ACAccount *account))success failure:(void (^)(NSError *findError))failure;
- (NSString *)getTwitterIDFromAccount:(ACAccount *)account;

@end
