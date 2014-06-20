@class SAMLoadingView;

@interface GoodTableView : UITableView <UITableViewDataSource, UITableViewDelegate> {
    int page;
    NSMutableArray *cellHeights;
    BOOL showNoResultsMessage;
    NSMutableArray *goods;
    NSString *goodsPath;
    SAMLoadingView *loadingView;

    BOOL tabsShowing;
    UIColor *tabColor;

    UIButton *all;
    UIButton *done;
    UIButton *todo;
}

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) UIViewController *parent;
@property int doneGoods;

- (void)showTabsWithColor:(UIColor *)color;
- (void)showTabs;
- (void)loadGoodsAtPath:(NSString *)path;
- (void)resetGood;
- (void)setupRefresh;
- (void)setupInfiniteScroll;

@end
