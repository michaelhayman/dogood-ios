#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface DGGoodListViewController : RootViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    IBOutlet UIView *headerView;
    NSArray *goods;
}

@end
