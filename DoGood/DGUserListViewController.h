@interface DGUserListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    NSArray *users;
}

@property (retain, nonatomic) NSString *type;
@property (retain, nonatomic) NSNumber *typeID;
@property (retain, nonatomic) NSString *query;

@end
