@interface DGUserSearchViewController : UIViewController <UISearchBarDelegate> {
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UITableView *tableView;
    NSArray *users;
}

@end
