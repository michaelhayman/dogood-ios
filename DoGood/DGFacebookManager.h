@class ACAccount;

typedef void (^PostCompletionBlock)(BOOL success, NSString *msg, ACAccount *account);
typedef void (^PostAccessBlock)(BOOL success, ACAccount *account, NSString *msg);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^FindFriendsBlock)(BOOL success, NSArray *msg, ACAccount *account);
typedef void (^FindIDBlock)(BOOL success, NSString *facebookID);

@interface DGFacebookManager : NSObject {
    NSDictionary *postOptions;
    NSString *appName;

    NSError *checkSettingsError;
    NSError *unableToPostError;
    NSError *noAccountError;
}

- (id)initWithAppName:(NSString *)name;
- (void)checkFacebookPostAccessWithSuccess:(PostAccessBlock)success failure:(ErrorBlock)failure;
- (void)promptForPostAccess;
- (void)postToFacebook:(NSMutableDictionary *)params andImage:(UIImage *)image withSuccess:(PostCompletionBlock)success failure:(ErrorBlock)failure;
- (void)findFacebookFriendsWithSuccess:(FindFriendsBlock)success failure:(ErrorBlock)failure;
- (void)findFacebookIDForAccount:(ACAccount *)account withSuccess:(FindIDBlock)success failure:(ErrorBlock)failure;

@end
