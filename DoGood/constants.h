#define APP_NAME @"Do Good"

#pragma mark - Paths -----
#define HOME 0
#if HOME
    #define LOCALHOST @"http://0.0.0.0:3002/"
#else
    #define LOCALHOST @"http://192.168.59.8"
#endif

#define DEVELOPMENT_LOGS 0
#define DEVELOPMENT 1
#if DEVELOPMENT
    #define JSON_API_HOST_ADDRESS @"http://0.0.0.0:3002/"
#else
    #define JSON_API_HOST_ADDRESS @"http://dogood-api.springbox.ca/"
#endif

#pragma mark - Convenience -----
#define iPad    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#pragma mark - Styles -----

// fonts
#define kSummaryCommentFont [UIFont systemFontOfSize:10]
#define kGoodCaptionFont [UIFont systemFontOfSize:14.]
#define MENU_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:20]
#define MENU_FONT_COLOR [UIColor blackColor]

// widths
#define kGoodRightColumnWidth 236.0
#define kCommentRightColumnWidth 248.0
#define kSummaryCommentRightColumnWidth 221.0

// named colours
#define MUD [UIColor colorWithRed:65/255.0 green:53.0/255.0 blue:41.0/255.0 alpha:1.0]
#define VIVID [UIColor colorWithRed:43.0/255.0 green:200.0/255.0 blue:35.0/255.0 alpha:1.0]
#define CREAM [UIColor colorWithRed:229.0/255.0 green:231.0/255.0 blue:213.0/255.0 alpha:1.0]
#define CLAY [UIColor colorWithRed:232.0/255.0 green:234.0/255.0 blue:219.0/255.0 alpha:1.0]

#define COLOUR_OFF_WHITE [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0]
#define COLOUR_GREEN [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]
#define COLOUR_BROWN [UIColor colorWithRed:179.0/255.0 green:113.0/255.0 blue:0.0/255.0 alpha:1.0]
#define COLOUR_REDDISH_BROWN [UIColor colorWithRed:171.0/255.0 green:71.0/255.0 blue:32.0/255.0 alpha:1.0]
#define COLOUR_YELLOW [UIColor colorWithRed:255.0/255.0 green:185.0/255.0 blue:0.0/255.0 alpha:1.0]

// descriptors
#define LINK_COLOUR VIVID

#define NEUTRAL_BACKGROUND_COLOUR [UIColor colorWithRed:237.0/255.0 green:234.0/255.0 blue:227.0/255.0 alpha:1.0]
#define BUTTON_COLOR VIVID
#define GRAYED_OUT [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.8]
#define ACTIVE [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]
#define REALLY_LIGHT_GRAY [UIColor colorWithRed:233.0/255.0 green:238.0/255.0 blue:226.0/255.0 alpha:1.0]
#define COLOUR_SEARCH_NETWORKS_BACKGROUND [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0]
#define TEXT_VIEW_BORDER_COLOR [UIColor colorWithRed:233.0/255.0 green:238.0/255.0 blue:226.0/255.0 alpha:1.0]
#define FONT_BAR_BUTTON_ITEM_BOLD @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 17]}

#pragma mark - User -----

// Paths
#define user_session_path @"/users/sign_in"
#define user_end_session_path @"/users/sign_out"
#define user_registration_path @"/users"
#define user_password_path @"/users/password"
#define user_update_path @"/users/update_profile"
#define user_update_password_path @"/users/update_password"
#define user_remove_avatar_path @"/users/remove_avatar"

// RKPassword
#define kDoGoodService @"DoGood"
#define kDoGoodAccount @"DoGood"

// Constants
extern NSString *const kDGUserCurrentUserIDDefaultsKey;
extern NSString* const kDGUserCurrentUserEmail;
extern NSString* const kDGUserCurrentUserPoints;
extern NSString* const kDGUserCurrentUserFullName;
extern NSString* const kDGUserCurrentUserLocation;
extern NSString* const kDGUserCurrentUserBiography;
extern NSString* const kDGUserCurrentUserPhone;
extern NSString* const kDGUserCurrentUserContactable;
extern NSString* const kDGUserCurrentUserAvatar;
extern NSString* const kDGUserCurrentUserTwitterID;
extern NSString* const kDGUserCurrentUserFacebookID;

#pragma mark - Errors -----
extern NSString *const DGErrorDomain;

#pragma mark - Notifications -----

// Notifications
extern NSString *const DGUserDidSignOutNotification;
extern NSString *const DGUserDidFailSilentAuthenticationNotification;
extern NSString* const DGConnectionFailure;

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
extern NSString* const DGUserDidClaimRewardNotification;

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

extern NSString* const DGUserDidSelectPersonForTextField;
extern NSString* const DGUserDidNotFindPeopleForTextField;

extern NSString* const DGUserDidSelectTagForTextField;
extern NSString* const DGUserDidNotFindTagsForTextField;

#pragma mark - Good

// Notifications
extern NSString* const DGUserDidPostGood;

// Text field cells
extern NSString* const UITextFieldCellIdentifier;

// rewards
extern NSString* const DGUserDidSelectRewards;

// explore - search
extern NSString* const DGUserDidStartSearchingTags;
extern NSString* const DGUserDidStartSearchingPeople;
extern NSString* const DGSearchTextFieldDidBeginEditing;
extern NSString* const DGSearchTextFieldDidEndEditing;
extern NSString* const DGUserDidStartBrowsingSearchTable;

extern NSString* const DGNomineeWasChosen;
extern NSString* const ExternalNomineeWasChosen;

#pragma mark - Convenience -----

#define NSNullIfNil(v) (v ? v : [NSNull null])

#pragma mark - Third parties -----

#define FOURSQUARE_API_URL       @"https://api.foursquare.com"
#define FOURSQUARE_CLIENT_ID     @"EWRCKLKQ4O2LVVYK1ADLNXHTBS3MTYY1JMNPNJCM3SZ1ATII"
#define FOURSQUARE_CLIENT_SECRET @"VZGH0QRJFF4AOU3WTXON0XZZQJ3YKMYLEUQ3ZRCQ0HZBDVTP"

#define TWITTER_CONSUMER_KEY @"yT577ApRtZw51q4NPMPPOQ"
#define TWITTER_CONSUMER_SECRET @"3neq3XqN5fO3obqwZoajavGFCUrC42ZfbrLXy5sCv8"
#define FACEBOOK_APP_ID @"151726295032833"


