@interface DGTextFieldSearchPeopleTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *users;
}

@property (nonatomic, retain) UITableView *tableView;

- (void)getUsersByName:(NSString *)searchText;
- (void)purge;

@end
