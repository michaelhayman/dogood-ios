@class DGNominee;
@class DGGood;

@interface NomineeCell : UITableViewCell <UIAlertViewDelegate>

@property (nonatomic, weak) DGNominee *nominee;

- (void)setValues;

@end
