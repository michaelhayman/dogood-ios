#import "RootViewController.h"
@class DGCategory;
@class UserOverview;

@interface DGGoodListViewController : RootViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    IBOutlet UIView *headerView;
    NSArray *goods;
    UserOverview *userView;

    
}

@property (nonatomic, retain) DGCategory *category;
@property (nonatomic, retain) NSNumber *goodID;

- (void)showWelcome;

@end
