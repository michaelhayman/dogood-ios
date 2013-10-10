@interface DGUserInvitesViewController : UIViewController {
    NSString *bodyText;
}

@property (nonatomic, retain) UIViewController *parent;

- (void)setInviteText;
- (void)setCustomText:(NSString *)string;

- (IBAction)sendViaText:(id)sender;
- (IBAction)sendViaEmail:(id)sender;

@end
