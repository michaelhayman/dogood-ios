@class DGCategory;
@class DGTag;
@class DGGood;
@class GoodTableView;
@class DGNominee;
@class DGUserInvitesViewController;

@interface DGGoodListViewController : DGViewController {
    __weak IBOutlet GoodTableView *goodTableView;
    DGUserInvitesViewController *invites;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSString *titleForPath;
@property (nonatomic, strong) DGCategory *category;
@property (nonatomic, strong) DGTag *tag;
@property (nonatomic, strong) DGUser *user;
@property (nonatomic, strong) DGNominee *nominee;
@property (nonatomic, strong) DGGood *goodForInvite;
@property (nonatomic, strong) NSNumber *goodID;
@property (nonatomic, strong) UIColor *color;
@property BOOL hideTabs;
@property BOOL goToSpecificTab;
@property BOOL showDoneGoods;

- (void)getGood;

@end
