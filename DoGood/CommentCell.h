@class DGComment;
#import <TTTAttributedLabel.h>

@interface CommentCell : UITableViewCell < TTTAttributedLabelDelegate> {
}

@property bool disableSelection;
@property (weak, nonatomic) DGComment *comment;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *commentBody;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentBodyHeight;
@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) IBOutlet UILabel *timePosted;

- (void)setValues;

@end
