#import "RootViewController.h"
@class DGCategory;

@interface DGGoodListViewController : RootViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    IBOutlet UIView *headerView;
    NSArray *goods;

}

@property (nonatomic, retain) DGCategory *category;

- (void)showWelcome;

@end
