@interface DGUserSettingsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

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
