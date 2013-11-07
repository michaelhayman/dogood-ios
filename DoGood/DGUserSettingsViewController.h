@class DGUserInvitesViewController;
@class DGPhotoPickerViewController;

@class DGTwitterManager;
@class DGFacebookManager;
#import "DGPhotoPickerViewController.h"

@interface DGUserSettingsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate, DGPhotoPickerViewControllerDelegate> {
    UITapGestureRecognizer *dismissTap;
    
    __weak IBOutlet UIImageView *avatar;
    __weak IBOutlet UIImageView *avatarOverlay;

    UIImage *imageToUpload;
    DGUserInvitesViewController *invites;
    DGPhotoPickerViewController *photos;

    NSString *twitterConnectedStatus;
    NSString *facebookConnectedStatus;

    DGTwitterManager *twitterManager;
    DGFacebookManager *facebookManager;
}

@property (weak, nonatomic) IBOutlet UITextField *name;

@end

typedef enum {
    accountOverview,
    accountDetails,
    findFriends,
    socialNetworks,
    session,
    settingsNumRows
} UserSettingsRowType;

typedef enum {
    fullName,
    biography,
    location,
    accountOverviewNumRows
} AccountOverviewRowType;

typedef enum {
    email,
    phone,
    resetPassword,
    yourContent,
    accountDetailsNumRows
} AccountDetailsRowType;

typedef enum {
    bySearching,
    byText,
    byEmail,
    findFriendsNumRows
} FindFriendsRowType;

typedef enum {
    twitter,
    facebook,
    socialNetworksNumRows
} SocialNetworksRowType;

typedef enum {
    signOut,
    sessionNumRows
} SessionRowType;
