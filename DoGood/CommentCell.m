#import "CommentCell.h"
#import "DGComment.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer* userGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGoodUserProfile)];
    [self.user setUserInteractionEnabled:YES];
    [self.user addGestureRecognizer:userGesture];

    UITapGestureRecognizer* avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGoodUserProfile)];
    [self.avatar setUserInteractionEnabled:YES];
    [self.avatar addGestureRecognizer:avatarGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setValues {
    self.user.text = self.comment.user.username;
    self.commentBody.text = self.comment.comment;
    [self.avatar setImageWithURL:[NSURL URLWithString:self.comment.user.avatar]];
}

#pragma mark - User profile helper
- (void)showGoodUserProfile {
    [DGUser openProfilePage:self.comment.user.userID inController:self.navigationController];
}

@end
