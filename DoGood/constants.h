#pragma mark - Convenience

#define iPad    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#pragma mark - Connectivity

#define checkConnectivity NO
#define checkAPI NO

// Third parties
#define FOURSQUARE_API_URL       @"https://api.foursquare.com"
#define FOURSQUARE_CLIENT_ID     @"EWRCKLKQ4O2LVVYK1ADLNXHTBS3MTYY1JMNPNJCM3SZ1ATII"
#define FOURSQUARE_CLIENT_SECRET @"VZGH0QRJFF4AOU3WTXON0XZZQJ3YKMYLEUQ3ZRCQ0HZBDVTP"

// Paths
#define JSON_API_HOST_ADDRESS @"http://0.0.0.0:3002/"

#pragma mark - User

// Paths
#define user_session_path @"/users/sign_in"
#define user_end_session_path @"/users/sign_out"
#define user_registration_path @"/users"
#define user_password_path @"/users/password"

// Styles
#define LINK_COLOUR [UIColor colorWithRed:5.0/255.0 green:171.0/255.0 blue:117.0/255.0 alpha:1.0]
// #define NEUTRAL_BACKGROUND_COLOUR [UIColor colorWithRed:224.0/255.0 green:228.0/255.0 blue:204.0/255.0 alpha:1.0]
// #define NEUTRAL_BACKGROUND_COLOUR [UIColor colorWithRed:230.0/255.0 green:223.0/255.0 blue:190.0/255.0 alpha:1.0]
// nice neutral
#define NEUTRAL_BACKGROUND_COLOUR [UIColor colorWithRed:237.0/255.0 green:234.0/255.0 blue:227.0/255.0 alpha:1.0]
// #define NEUTRAL_BACKGROUND_COLOUR [UIColor colorWithRed:197.0/255.0 green:240.0/255.0 blue:249.0/255.0 alpha:1.0]
// poo green
//#define BUTTON_COLOR [UIColor colorWithRed:173.0/255.0 green:183.0/255.0 blue:36.0/255.0 alpha:1.0]
// brown
#define BUTTON_COLOR [UIColor colorWithRed:122.0/255.0 green:106.0/255.0 blue:83.0/255.0 alpha:1.0]
#define GRAYED_OUT [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:0.3]
#define ACTIVE [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]


// RKPassword
#define kDoGoodService @"DoGood"
#define kDoGoodAccount @"DoGood"

// Constants
extern NSString *const kDGUserCurrentUserIDDefaultsKey;
extern NSString* const kDGUserCurrentUserEmail;
extern NSString* const kDGUserCurrentUserUsername;
extern NSString* const kDGUserCurrentUserFullName;
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

extern NSString* const DGUserUpdatePointsNotification;
extern NSString* const DGUserDidUpdatePointsNotification;

extern NSString* const DGUserClaimRewardNotification;

extern NSString* const DGUserDidUpdateFollowingsNotification;

#pragma mark - Good

// Notifications
extern NSString* const DGUserDidPostGood;

// Text field cells
extern NSString* const UITextFieldCellIdentifier;
