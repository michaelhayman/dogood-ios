@interface DGUser : NSObject

@property (nonatomic, copy) NSNumber* userID;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* password_confirmation;
@property (nonatomic, copy) NSString* full_name;
@property (nonatomic, copy) NSString* phone;
@property (nonatomic, copy) NSNumber* points;
@property (nonatomic, copy) NSNumber* contactable;
@property (nonatomic, copy) NSNumber* followers_count;
@property (nonatomic, copy) NSNumber* following_count;
@property (nonatomic, copy) NSNumber* current_user_following;
@property (nonatomic, copy) NSNumber* liked_goods_count;
@property (nonatomic, copy) NSNumber* posted_or_followed_goods_count;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, copy) NSString* avatar;
@property (nonatomic, copy) UIImage* image;

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

#pragma mark - Points
- (void)updatePoints;

@end

