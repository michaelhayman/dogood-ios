#import "DGExploreSearchTagsTableViewController.h"

@interface DGExploreSearchTagsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *tags;
    bool showNoResultsMessage;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UINavigationController *navigationController;

- (void)getTagsByName:(NSString *)searchText;
- (void)purge;

@end
