@class DGUserInvitesViewController;
@class DGPhotoPickerViewController;

@class DGTwitterManager;
@class DGFacebookManager;
@protocol DGUserSettingsViewControllerDelegate;
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
@property (nonatomic, weak) id<DGUserSettingsViewControllerDelegate> delegate;

@end

@protocol DGUserSettingsViewControllerDelegate <NSObject>

- (void)childViewControllerDidUpdatePhoto:(UIImage *)image;

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
    help,
    terms,
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
