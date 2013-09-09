#import "DGExploreSearchTagsTableViewController.h"

@interface DGExploreSearchTagsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITableView *tableView;
    NSMutableArray *tags;
}

@end
