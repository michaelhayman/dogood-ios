@class DGNominee;
@class DGGood;

@interface NomineeCell : UITableViewCell {
    UIButton *inviteButton;
}

@property (nonatomic, weak) DGNominee *nominee;

- (void)setValues;

@end