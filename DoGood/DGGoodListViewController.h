#import "RootViewController.h"
@class DGCategory;
@class UserOverview;
@class DGTag;
@class DGGood;

@interface DGGoodListViewController : RootViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    IBOutlet UIView *headerView;
    NSArray *goods;
    NSMutableArray *cellHeights;
    UserOverview *userView;
}

@property (nonatomic, retain) DGCategory *category;
@property (nonatomic, retain) DGTag *tag;
@property (nonatomic, retain) NSNumber *goodID;

- (void)showWelcome;
- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath withGood:(DGGood *)good;

@end
