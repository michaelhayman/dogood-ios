@class DGUserInvitesViewController;
@interface DGUserSettingsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    UITapGestureRecognizer *dismissTap;
    
    __weak IBOutlet UIImageView *avatar;
    __weak IBOutlet UIImageView *avatarOverlay;
    UIImage *imageToUpload;
    UIImage *resizedImage;
    UIActionSheet *photoSheet;
    DGUserInvitesViewController *invites;
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
