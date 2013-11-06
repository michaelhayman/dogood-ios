#import "DGExploreSearchTagsTableViewController.h"

@interface DGExploreSearchTagsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *tags;
    bool showNoResultsMessage;
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UINavigationController *navigationController;

- (void)getTagsByName:(NSString *)searchText;
- (void)purge;

@end
