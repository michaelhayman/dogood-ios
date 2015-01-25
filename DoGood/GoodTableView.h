@class SAMLoadingView;
@class DGGood;

@interface GoodTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property int page;
@property (nonatomic, strong) NSMutableArray *cellHeights;
@property (nonatomic, strong) NSMutableArray *goods;
@property (nonatomic, copy) NSString *goodsPath;
@property (nonatomic, strong) SAMLoadingView *loadingView;

@property BOOL tabsShowing;
@property (nonatomic, retain) UIColor *tabColor;

@property (nonatomic, retain) UIButton *all;
@property (nonatomic, retain) UIButton *done;
@property (nonatomic, retain) UIButton *todo;

@property BOOL showNoResultsMessage;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) UIViewController *parent;
@property int doneGoods;

- (void)showTabsWithColor:(UIColor *)color;
- (void)showTabs;
- (void)loadGoodsAtPath:(NSString *)path;
- (void)resetGood;
- (void)setupRefresh;
- (void)setupInfiniteScroll;
- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath withGood:(DGGood *)good;

@end
