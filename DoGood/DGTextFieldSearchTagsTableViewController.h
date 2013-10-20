@interface DGTextFieldSearchTagsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *tags;
    BOOL reverseScroll;
}

@property (nonatomic, retain) UITableView *tableView;

- (void)getTagsByName:(NSString *)searchText;
- (void)purge;
- (id)initWithScrolling:(BOOL)reverse;

@end
