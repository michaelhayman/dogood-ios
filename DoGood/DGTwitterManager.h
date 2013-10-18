@class ACAccount;
typedef void (^ErrorBlock)(NSError *error);

typedef void (^PostAccessBlock)(BOOL success, NSString *msg);
typedef void (^PostCompletionBlock)(BOOL success, NSString *msg, ACAccount *account);
typedef void (^FindFriendsBlock)(BOOL success, NSArray *msg, ACAccount *account);

@interface DGTwitterManager : NSObject {
    NSDictionary *postOptions;
    NSString *appName;

    NSError *checkSettingsError;
    NSError *unableToPostError;
    NSError *noAccountError;
}

- (id)initWithAppName:(NSString *)name;
- (void)checkTwitterPostAccessWithSuccess:(PostAccessBlock)success failure:(ErrorBlock)failure;
- (void)promptForPostAccess;
- (void)postToTwitter:(NSString *)status andImage:(UIImage *)image withSuccess:(PostCompletionBlock)success failure:(ErrorBlock)failure;
- (void)findTwitterFriendsWithSuccess:(FindFriendsBlock)success failure:(ErrorBlock)failure;
- (NSString *)getTwitterIDFromAccount:(ACAccount *)account;

@end
