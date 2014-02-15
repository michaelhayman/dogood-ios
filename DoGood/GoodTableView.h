@class SAMLoadingView;

@interface GoodTableView : UITableView <UITableViewDataSource, UITableViewDelegate> {
    int page;
    NSMutableArray *cellHeights;
    BOOL showNoResultsMessage;
    NSMutableArray *goods;
    NSString *goodsPath;
    SAMLoadingView *loadingView;
}

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) UIViewController *parent;

- (void)loadGoodsAtPath:(NSString *)path;
- (void)resetGood;
- (void)setupRefresh;

@end
