#pragma mark - Convenience

#define iPad    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#pragma mark - Connectivity

#define checkConnectivity NO
#define checkAPI NO

// Paths
#define JSON_API_HOST_ADDRESS @"http://0.0.0.0:3002/"

#pragma mark - User

// Paths
#define user_session_path @"/users/sign_in"
#define user_end_session_path @"/users/sign_out"
#define user_registration_path @"/users"
#define user_password_path @"/users/password"

// RKPassword
#define kDoGoodService @"DoGood"
#define kDoGoodAccount @"DoGood"

// Constants
extern NSString *const kDGUserCurrentUserIDDefaultsKey;
extern NSString* const kDGUserCurrentUserEmail;
extern NSString* const kDGUserCurrentUserUsername;
extern NSString* const kDGUserCurrentUserName;
extern NSString* const kDGUserCurrentUserPhone;
extern NSString* const kDGUserCurrentUserContactable;

// Notifications
extern NSString *const DGUserDidSignOutNotification;

extern NSString* const DGUserDidSignInNotification;
extern NSString* const DGUserDidFailSignInNotification;

extern NSString* const DGUserDidCreateAccountNotification;
extern NSString* const DGUserDidFailCreateAccountNotification;

extern NSString* const DGUserDidUpdateAccountNotification;
extern NSString* const DGUserDidFailUpdateAccountNotification;

extern NSString* const DGUserEmailIsUnique;
extern NSString* const DGUserEmailIsNotUnique;

extern NSString* const DGUserDidUpdatePasswordNotification;
extern NSString* const DGUserDidFailUpdatePasswordNotification;

extern NSString* const DGUserDidSendPasswordNotification;
extern NSString* const DGUserDidFailSendPasswordNotification;

extern NSString* const DGUserInfoDidLoad;

#pragma mark - Good

// Notifications
extern NSString* const DGUserDidPostGood;
