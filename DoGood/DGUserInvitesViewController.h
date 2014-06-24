@interface DGUserInvitesViewController : DGViewController {
    NSString *recipient;
    NSString *bodyText;
    NSString *subjectText;
}

@property (nonatomic, weak) UIViewController *parent;
@property BOOL isHTML;

- (void)setInviteText;
- (void)setInviteHTML;
- (void)setCustomText:(NSString *)body withSubject:(NSString *)subject;
- (void)setCustomText:(NSString *)body withSubject:(NSString *)subject toRecipient:(NSString *)to;

- (IBAction)sendViaText:(id)sender;
- (IBAction)sendViaEmail:(id)sender;

@end
