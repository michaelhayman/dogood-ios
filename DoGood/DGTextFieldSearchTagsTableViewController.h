@interface DGTextFieldSearchTagsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *tags;
    BOOL reverseScroll;
}

@property (nonatomic, weak) UITableView *tableView;

- (void)getTagsByName:(NSString *)searchText;
- (void)purge;
- (id)initWithScrolling:(BOOL)reverse;

@end
