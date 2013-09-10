@interface DGTextFieldSearchPeopleTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    // __weak IBOutlet UITableView *tableView;
    NSMutableArray *users;
    bool showNoResultsMessage;
}

@property (nonatomic, retain) UITableView *tableView;

- (void)getUsersByName:(NSString *)searchText;
- (void)purge;

@end
