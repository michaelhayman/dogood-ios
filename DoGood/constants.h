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
static NSString* const kDGUserCurrentUserIDDefaultsKey = @"kDGUserCurrentUserIDDefaultsKey";
static NSString* const kDGUserCurrentUserEmail = @"kDGUserCurrentUserEmail";
static NSString* const kDGUserCurrentUserFirstName = @"kDGUserCurrentUserFirstName";
static NSString* const kDGUserCurrentUserLastName = @"kDGUserCurrentUserLastName";
static NSString* const kDGUserCurrentUserContactable = @"kDGUserCurrentUserContactable";

// Notifications
static NSString* const DGUserDidSignOutNotification = @"DGUserDidSignOutNotification";

static NSString* const DGUserDidSignInNotification = @"DGUserDidSignInNotification";
static NSString* const DGUserDidFailSignInNotification = @"DGUserDidFailSignInNotification";

static NSString* const DGUserDidCreateAccountNotification = @"DGUserDidCreateAccountNotification";
static NSString* const DGUserDidFailCreateAccountNotification = @"DGUserDidFailCreateAccountNotification";

static NSString* const DGUserDidUpdateAccountNotification = @"DGUserDidUpdateAccountNotification";
static NSString* const DGUserDidFailUpdateAccountNotification = @"DGUserDidFailUpdateAccountNotification";

static NSString* const DGUserEmailIsUnique = @"DGUserEmailIsUnique";
static NSString* const DGUserEmailIsNotUnique = @"DGUserEmailIsNotUnique";

static NSString* const DGUserDidUpdatePasswordNotification = @"DGUserDidUpdatePasswordNotification";
static NSString* const DGUserDidFailUpdatePasswordNotification = @"DGUserDidFailUpdatePasswordNotification";

static NSString* const DGUserDidSendPasswordNotification = @"DGUserDidSendPasswordNotification";
static NSString* const DGUserDidFailSendPasswordNotification = @"DGUserDidFailSendPasswordNotification";

static NSString* const DGUserInfoDidLoad = @"DGUserInfoDidLoad";

