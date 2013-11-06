@interface DGUserInvitesViewController : UIViewController {
    NSString *bodyText;
    NSString *subjectText;
}

@property (nonatomic, weak) UIViewController *parent;

- (void)setInviteText;
- (void)setCustomText:(NSString *)body withSubject:(NSString *)subject;

- (IBAction)sendViaText:(id)sender;
- (IBAction)sendViaEmail:(id)sender;

@end
