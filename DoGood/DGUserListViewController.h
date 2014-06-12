@class SAMLoadingView;

@interface DGUserListViewController : DGViewController <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITableView *tableView;
    BOOL showNoResultsMessage;
    NSArray *users;
    SAMLoadingView *loadingView;
}

@property (retain, nonatomic) NSString *type;
@property (retain, nonatomic) NSNumber *typeID;
@property (retain, nonatomic) NSString *query;

@end
