#define iPad    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define kDoGoodService @"DoGood"
#define kDoGoodAccount @"DoGood"

#define checkConnectivity NO
#define checkAPI NO

// Paths
#define JSON_API_HOST_ADDRESS @"http://0.0.0.0:3002/"
#define user_session_path @"/users/sign_in"
#define user_end_session_path @"/users/sign_out"
#define user_registration_path @"/users"
#define user_password_path @"/users/password"

// Constants
extern NSString *const kDGUserCurrentUserIDDefaultsKey;
extern NSString* const kDGUserCurrentUserEmail;
extern NSString* const kDGUserCurrentUserFirstName;
extern NSString* const kDGUserCurrentUserLastName;
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

