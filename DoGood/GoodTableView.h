@class SAMLoadingView;

@interface GoodTableView : UITableView <UITableViewDataSource, UITableViewDelegate> {
    int page;
    NSMutableArray *cellHeights;
    BOOL showNoResultsMessage;
    NSMutableArray *goods;
    NSString *goodsPath;
    SAMLoadingView *loadingView;

    UISegmentedControl *tabControl;
    BOOL doneGoods;
    BOOL tabsShowing;
}

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) UIViewController *parent;

- (void)showTabs;
- (void)loadGoodsAtPath:(NSString *)path;
- (void)resetGood;
- (void)setupRefresh;
- (void)setupInfiniteScroll;

@end
