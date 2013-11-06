#import "RootViewController.h"
@class DGCategory;
@class UserOverview;
@class DGTag;
@class DGGood;
@class DGLoadingView;

@interface DGGoodListViewController : RootViewController <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITableView *tableView;
    int page;
    bool showNoResultsMessage;
    NSMutableArray *goods;
    NSMutableArray *cellHeights;
    UserOverview *userView;
}

@property (nonatomic, strong) DGLoadingView *loadingView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSString *titleForPath;
@property (nonatomic, weak) DGCategory *category;
@property (nonatomic, weak) DGTag *tag;
@property (nonatomic, strong) NSNumber *goodID;
@property (nonatomic, weak) UINavigationController *loadController;

- (void)showWelcome;
- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath withGood:(DGGood *)good;
- (void)getGood;
- (void)reloadGood;
- (void)loadMoreGood;
- (void)resetGood;
- (void)initializeTable;
- (void)setupRefresh;
- (void)setupInfiniteScroll;

@end
