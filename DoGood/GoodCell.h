@class DGGood;
@class DGGoodListViewController;
// @class TTTAttributedLabel;
// @class TTTAttributedLabelDelegate;
#import <TTTAttributedLabel.h>

@interface GoodCell : UITableViewCell <UIActionSheetDelegate, TTTAttributedLabelDelegate> {
    UIActionSheet *moreOptionsSheet;
    UIActionSheet *shareOptionsSheet;
    __weak IBOutlet NSLayoutConstraint *commentBoxHeight;
}

@property (weak, nonatomic) IBOutlet UIImageView *overviewImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet UILabel *regoods;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property (weak, nonatomic) IBOutlet UIView *comments;
@property (strong, nonatomic) TTTAttributedLabel *commentBlock;

@property (weak, nonatomic) IBOutlet UILabel *likes;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UIButton *like;
@property (weak, nonatomic) IBOutlet UIButton *comment;
@property (weak, nonatomic) IBOutlet UIButton *regood;
@property (weak, nonatomic) IBOutlet UIButton *moreOptions;
@property (weak, nonatomic) DGGood *good;
@property (weak, nonatomic) DGGoodListViewController *parent;
@property (weak, nonatomic) UINavigationController *navigationController;

- (void)setValues;

@end
