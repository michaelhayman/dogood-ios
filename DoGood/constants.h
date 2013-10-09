#pragma mark - Convenience

#define iPad    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#pragma mark - Connectivity

#define checkConnectivity NO
#define checkAPI NO

#pragma mark - Third parties

#define FOURSQUARE_API_URL       @"https://api.foursquare.com"
#define FOURSQUARE_CLIENT_ID     @"EWRCKLKQ4O2LVVYK1ADLNXHTBS3MTYY1JMNPNJCM3SZ1ATII"
#define FOURSQUARE_CLIENT_SECRET @"VZGH0QRJFF4AOU3WTXON0XZZQJ3YKMYLEUQ3ZRCQ0HZBDVTP"

#define TWITTER_CONSUMER_KEY @"yT577ApRtZw51q4NPMPPOQ"
#define TWITTER_CONSUMER_SECRET @"3neq3XqN5fO3obqwZoajavGFCUrC42ZfbrLXy5sCv8"

// Paths
// #define JSON_API_HOST_ADDRESS @"http://192.168.1.3:3002/"
#define JSON_API_HOST_ADDRESS @"http://0.0.0.0:3002/"

#pragma mark - User

// Paths
#define user_session_path @"/users/sign_in"
#define user_end_session_path @"/users/sign_out"
#define user_registration_path @"/users"
#define user_password_path @"/users/password"
#define user_update_path @"/users/update_profile"
#define user_remove_avatar_path @"/users/remove_avatar"

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
#define GRAYED_OUT [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.8]
#define ACTIVE [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]
#define REALLY_LIGHT_GRAY [UIColor colorWithRed:233.0/255.0 green:238.0/255.0 blue:226.0/255.0 alpha:1.0]

// global text
#define MENU_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:20]

#define FONT_BAR_BUTTON_ITEM_BOLD @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 17]}
// global colours
#define COLOUR_OFF_WHITE [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0]
#define COLOUR_GREEN [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:134.0/255.0 alpha:1.0]
#define COLOUR_BROWN [UIColor colorWithRed:179.0/255.0 green:113.0/255.0 blue:0.0/255.0 alpha:1.0]
#define COLOUR_REDDISH_BROWN [UIColor colorWithRed:171.0/255.0 green:71.0/255.0 blue:32.0/255.0 alpha:1.0]
#define COLOUR_YELLOW [UIColor colorWithRed:255.0/255.0 green:185.0/255.0 blue:0.0/255.0 alpha:1.0]
//#define COLOR_ORANGE

#define MENU_FONT_COLOR [UIColor blackColor]

// RKPassword
#define kDoGoodService @"DoGood"
#define kDoGoodAccount @"DoGood"

// Constants
extern NSString *const kDGUserCurrentUserIDDefaultsKey;
extern NSString* const kDGUserCurrentUserEmail;
extern NSString* const kDGUserCurrentUserUsername;
extern NSString* const kDGUserCurrentUserFullName;
extern NSString* const kDGUserCurrentUserLocation;
extern NSString* const kDGUserCurrentUserBiography;
extern NSString* const kDGUserCurrentUserPhone;
extern NSString* const kDGUserCurrentUserContactable;
extern NSString* const kDGUserCurrentUserAvatar;
extern NSString* const kDGUserCurrentUserTwitterID;
extern NSString* const kDGUserCurrentUserFacebookID;

// Notifications
extern NSString *const DGUserDidSignOutNotification;

extern NSString* const DGUserDidSignInNotification;
extern NSString* const DGUserDidFailSignInNotification;

extern NSString* const DGUserDidCreateAccountNotification;
extern NSString* const DGUserDidFailCreateAccountNotification;

extern NSString* const DGUserDidUpdateAccountNotification;
extern NSString* const DGUserDidUpdateAvatarNotification;
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

extern NSString* const DGUserDidAddPhotoNotification;
extern NSString* const DGUserDidRemovePhotoNotification;

extern NSString* const DGUserDidUpdateFollowingsNotification;

extern NSString* const DGUserDidConnectToTwitter;
extern NSString* const DGUserDidDisconnectFromTwitter;

extern NSString* const DGUserIsConnectedToTwitter;
extern NSString* const DGUserIsNotConnectedToTwitter;

extern NSString* const DGUserDidCheckIfTwitterIsConnected;

extern NSString* const DGUserDidFindFriendsOnTwitter;
extern NSString* const DGUserDidFailFindFriendsOnTwitter;

extern NSString* const DGUserDidConnectToFacebook;
extern NSString* const DGUserDidDisconnectFromFacebook;
extern NSString* const DGUserDidFailToConnectToFacebook;

extern NSString* const DGUserDidCheckIfFacebookIsConnectedAndHasPermissions;
extern NSString* const DGUserDidCheckIfFacebookIsConnected;
extern NSString* const DGUserDidFindFriendsOnFacebook;

extern NSString* const DGUserDidCheckIfAddressBookIsConnected;

extern NSString* const DGUserDidToggleMenu;

#pragma mark - Good

// Notifications
extern NSString* const DGUserDidPostGood;

// Text field cells
extern NSString* const UITextFieldCellIdentifier;

// explore - search
extern NSString* const DGUserDidStartSearchingTags;
extern NSString* const DGUserDidStartSearchingPeople;
extern NSString* const DGSearchTextFieldDidBeginEditing;
extern NSString* const DGSearchTextFieldDidEndEditing;
extern NSString* const DGUserDidStartBrowsingSearchTable;

// convenience methods
#define NSNullIfNil(v) (v ? v : [NSNull null])
