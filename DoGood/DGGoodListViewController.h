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

@property (nonatomic, retain) DGLoadingView *loadingView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *titleForPath;
@property (nonatomic, retain) DGCategory *category;
@property (nonatomic, retain) DGTag *tag;
@property (nonatomic, retain) NSNumber *goodID;
@property (nonatomic, retain) UINavigationController *loadController;

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
