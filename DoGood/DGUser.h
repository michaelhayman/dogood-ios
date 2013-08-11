@interface DGUser : NSObject

@property (nonatomic, copy) NSNumber* userID;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* first_name;
@property (nonatomic, copy) NSString* last_name;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* password_confirmation;
@property (nonatomic, copy) NSNumber* contactable;
@property (nonatomic, copy) NSNumber* terms_accepted;
@property (nonatomic, copy) NSString* message;

#pragma mark - Class methods
+ (DGUser*)currentUser;
+ (void)setCurrentUser:(DGUser*)user;
+ (void)signInWasSuccessful;

#pragma mark - Sign In

+ (void)verifySavedUser;

+ (NSString *)basicAuthorizationHeader;

+ (void)setAuthorizationHeader;

- (BOOL)isSignedIn;

#pragma mark - Send Password
- (void)sendPasswordToEmail:(NSString*)email;
+ (void)setNewPassword:(NSString *)password;

#pragma mark - Sign Out
- (void)signOutWithMessage:(BOOL)showMessage;

@end

