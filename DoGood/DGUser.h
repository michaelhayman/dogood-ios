@interface DGUser : NSObject

@property (nonatomic, copy) NSNumber* userID;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* password_confirmation;
@property (nonatomic, copy) NSString* full_name;
@property (nonatomic, copy) NSString* phone;
@property (nonatomic, copy) NSString* biography;
@property (nonatomic, copy) NSString* location;
@property (nonatomic, copy) NSString* rank;

@property (nonatomic, copy) NSNumber* points;
@property (nonatomic, copy) NSNumber* contactable;
@property (nonatomic, copy) NSNumber* followers_count;
@property (nonatomic, copy) NSNumber* following_count;
@property (nonatomic, copy) NSNumber* current_user_following;
@property (nonatomic, copy) NSNumber* voted_goods_count;
@property (nonatomic, copy) NSNumber* followed_goods_count;
@property (nonatomic, copy) NSNumber* nominations_by_user_goods_count;
@property (nonatomic, copy) NSNumber* nominations_for_user_goods_count;
@property (nonatomic, copy) NSNumber* help_wanted_by_user_goods_count;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, copy) NSString* avatar_url;
@property (nonatomic, copy) UIImage* avatar;
#pragma mark - Social
@property (nonatomic, copy) NSString* twitter_id;
@property (nonatomic, copy) NSString* facebook_id;

#pragma mark - Class methods
+ (DGUser*)currentUser;
+ (void)setCurrentUser:(DGUser*)user;
+ (void)signInWasSuccessful;

#pragma mark - Welcome screen
+ (BOOL)showWelcomeMessage;
+ (void)welcomeMessageShown;

#pragma mark - HTTP Headers
+ (void)setAuthorizationHeader;
+ (void)setUpUserAuthentication;
+ (void)setBasicHTTPAccessFromAuthenticationNotification:(NSNotification*)notification;

#pragma mark - Sign In
+ (void)verifySavedUser;

- (BOOL)isSignedIn;

+ (void) assignDefaults;

#pragma mark - Send Password
+ (void)setNewPassword:(NSString *)password;

#pragma mark - Sign Out
- (void)signOutWithMessage:(BOOL)showMessage;

#pragma mark - Points
- (void)updatePoints;

#pragma mark - Social
typedef void (^SocialSuccessBlock)(BOOL success);
typedef void (^ErrorBlock)(NSError *error);

- (void)saveSocialID:(NSString *)socialID withType:(NSString *)socialType success:(SocialSuccessBlock)completion failure:(ErrorBlock)failure;
- (void)saveSocialID:(NSString *)socialID withType:(NSString *)socialType;

#pragma mark - Decoration
- (NSURL *)avatarURL;

#pragma mark - Profile helpers
+ (void)openProfilePage:(NSNumber *)userID inController:(UINavigationController *)nav;
- (BOOL)authorizeAccess:(UIViewController *)controller;

#pragma mark - Formatters
- (NSString *)pointsText;

- (BOOL)hasBeenNominated;
- (BOOL)hasFollowedGoods;
- (BOOL)hasVotes;
- (BOOL)hasPostedNominations;
- (BOOL)hasPostedHelpWantedGoods;
- (BOOL)isCurrentUser;
- (BOOL)hasAvatar;

@end
