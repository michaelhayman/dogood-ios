@class DGPostGoodNomineeSearchViewController;

@interface DGUserSearchViewController : UIViewController <UISearchBarDelegate> {
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UITableView *tableView;
    NSArray *users;
}

@property (nonatomic, retain) NSString *searchType;
@property (nonatomic, weak) DGPostGoodNomineeSearchViewController *parent;

@end
