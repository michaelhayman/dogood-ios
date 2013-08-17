#import "RootViewController.h"

@interface DGUserProfileViewController : RootViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIButton *centralButton;
    __weak IBOutlet UIImageView *avatarOverlay;
    __weak IBOutlet UIImageView *avatar;
    __weak IBOutlet UILabel *name;
    DGUser *user;
    bool ownProfile;
    __weak IBOutlet UILabel *followers;
    __weak IBOutlet UILabel *following;
    NSArray *goods;
    __weak IBOutlet UIView *headerView;
    
    __weak IBOutlet UITableView *tableView;
    
    NSString *selectedTab;
    __weak IBOutlet UIButton *goodsButton;
    __weak IBOutlet UIButton *likesButton;
    
}

@property (weak, nonatomic) NSNumber *userID;
@property bool fromMenu;

- (void)toggleFollow;
- (void)openSettings;

@end
