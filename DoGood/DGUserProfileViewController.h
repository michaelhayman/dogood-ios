#import "AuthenticateView.h"

@class DGUserInvitesViewController;
@class DGGoodListViewController;
@class SAMLoadingView;
@class DGUserGoodsTableView;

@interface DGUserProfileViewController : DGViewController <UIActionSheetDelegate, UIAlertViewDelegate> {
    __weak IBOutlet UIButton *centralButton;
    __weak IBOutlet UIImageView *avatarOverlay;
    __weak IBOutlet UIImageView *avatar;
    __weak IBOutlet UILabel *name;
    DGUser *user;
    BOOL reloadProfileOnView;
    BOOL reloadPhotoOnView;

    __weak IBOutlet UILabel *followers;
    __weak IBOutlet UILabel *following;
    NSArray *goods;
    __weak IBOutlet UIView *headerView;
    
    __weak IBOutlet UITableView *tableView;
    
    NSString *selectedTab;
    __weak IBOutlet UIButton *goodsButton;
    __weak IBOutlet UIButton *likesButton;

    DGUserInvitesViewController *invites;
    __weak IBOutlet DGUserGoodsTableView *userGoodsTableView;

    UIActionSheet *moreOptionsSheet;
    UIActionSheet *shareOptionsSheet;
    SAMLoadingView *loadingView;
    __weak IBOutlet AuthenticateView *authenticateView;
}

@property (strong, nonatomic) NSNumber *userID;
@property bool fromMenu;

- (void)toggleFollow;
- (void)openSettings;

@end
