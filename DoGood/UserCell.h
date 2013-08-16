#import <TTTAttributedLabel.h>

@interface UserCell : UITableViewCell <UIActionSheetDelegate, TTTAttributedLabelDelegate> {
}

@property (weak, nonatomic) IBOutlet DGUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIButton *follow;
@property (weak, nonatomic) UINavigationController *navigationController;

- (void)setValues;

@end
