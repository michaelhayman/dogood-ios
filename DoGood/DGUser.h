@interface DGUser : NSObject

@property (nonatomic, copy) NSNumber* userID;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* password_confirmation;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* phone;
@property (nonatomic, copy) NSNumber* contactable;
@property (nonatomic, copy) NSString* message;

#pragma mark - Class methods
+ (DGUser*)currentUser;
+ (void)setCurrentUser:(DGUser*)user;
+ (void)signInWasSuccessful;

#pragma mark - Sign In

+ (void)verifySavedUser;

+ (void)setAuthorizationHeader;

- (BOOL)isSignedIn;

#pragma mark - Send Password
+ (void)setNewPassword:(NSString *)password;

#pragma mark - Sign Out
- (void)signOutWithMessage:(BOOL)showMessage;

@end

