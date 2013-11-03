@interface DGUserListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITableView *tableView;
    NSArray *users;
}

@property (retain, nonatomic) NSString *type;
@property (retain, nonatomic) NSNumber *typeID;
@property (retain, nonatomic) NSString *query;

@end
