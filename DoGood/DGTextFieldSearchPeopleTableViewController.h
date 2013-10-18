@interface DGTextFieldSearchPeopleTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *users;
    bool showNoResultsMessage;
}

@property (nonatomic, retain) UITableView *tableView;

- (void)getUsersByName:(NSString *)searchText;
- (void)purge;

@end
