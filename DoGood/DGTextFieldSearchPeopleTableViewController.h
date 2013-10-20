@interface DGTextFieldSearchPeopleTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *users;
    BOOL reverseScroll;
}

@property (nonatomic, retain) UITableView *tableView;

- (void)getUsersByName:(NSString *)searchText;
- (void)purge;
- (id)initWithScrolling:(BOOL)reverse;

@end
