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

    NSString *connectedText;
    NSString *disconnectedText;

    DGTwitterManager *twitterManager;
    DGFacebookManager *facebookManager;

    __weak IBOutlet UILabel *versionNumber;
}

@property (weak, nonatomic) IBOutlet UITextField *name;

@end

typedef enum {
    accountOverview,
    accountDetails,
    findFriends,
    socialNetworks,
    session,
    settingsNumSections
} UserSettingsSectionType;

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
