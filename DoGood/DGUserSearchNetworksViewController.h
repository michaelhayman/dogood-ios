@interface DGUserSearchNetworksViewController : UIViewController {

    // authorized
    __weak IBOutlet UIView *authorizedView;
    __weak IBOutlet UIView *authorizedHeader;
    __weak IBOutlet UILabel *contentDescription;
    __weak IBOutlet UITableView *tableView;

    // unauthorized
    __weak IBOutlet UIView *unauthorizedView;
    __weak IBOutlet UIImageView *unauthorizedBackground;
    __weak IBOutlet UIButton *authorizeButton;
    __weak IBOutlet UILabel *noUsersLabel;
}

- (void)showAuthorized;
- (void)showUnauthorized;

@end
