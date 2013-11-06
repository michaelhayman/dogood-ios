@interface DGExploreSearchPeopleTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *users;
    bool showNoResultsMessage;
}

@property (nonatomic, weak) UITableView *tableView;

- (void)getUsersByName:(NSString *)searchText;
- (void)purge;

@end
