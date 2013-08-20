@interface DGUserInvitesViewController : UIViewController {
}

@property (nonatomic, retain) UIViewController *parent;

- (IBAction)inviteViaText:(id)sender;
- (IBAction)inviteViaEmail:(id)sender;

@end
