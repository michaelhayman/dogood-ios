@class DGUserInvitesViewController;
@interface DGUserFindFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    
    __weak IBOutlet UISegmentedControl *tabs;
    __weak IBOutlet UILabel *contentDescription;
    __weak IBOutlet UITableView *tableView;
    __weak IBOutlet UIView *internalSearch;
    NSArray *users;
    __weak IBOutlet UIView *tableHeader;
    DGUserInvitesViewController *invites;
}

- (IBAction)searchForPeople:(id)sender;
- (IBAction)inviteViaText:(id)sender;
- (IBAction)inviteViaEmail:(id)sender;

@end
