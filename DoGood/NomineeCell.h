@class DGNominee;
@class DGGood;

@interface NomineeCell : UITableViewCell <UIAlertViewDelegate> {
    UIButton *inviteButton;
}

@property (nonatomic, weak) DGNominee *nominee;

- (void)setValues;
- (void)invite;

@end
