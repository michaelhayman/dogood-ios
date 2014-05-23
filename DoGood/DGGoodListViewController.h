@class DGCategory;
@class UserOverview;
@class DGTag;
@class DGGood;
@class GoodTableView;

@interface DGGoodListViewController : DGViewController {
    UserOverview *userView;
    __weak IBOutlet GoodTableView *goodTableView;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSString *titleForPath;
@property (nonatomic, strong) DGCategory *category;
@property (nonatomic, strong) DGTag *tag;
@property (nonatomic, strong) DGUser *user;
@property (nonatomic, strong) NSNumber *goodID;
@property (nonatomic, strong) UIColor *color;
@property BOOL hideTabs;

- (void)getGood;

@end
