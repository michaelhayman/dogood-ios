@interface DGTextFieldSearchTagsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *tags;
}

@property (nonatomic, retain) UITableView *tableView;

- (void)getTagsByName:(NSString *)searchText;
- (void)purge;

@end
