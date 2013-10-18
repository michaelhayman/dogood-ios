#import "CommentCell.h"
#import "DGComment.h"
#import "DGEntity.h"
#import "DGTag.h"
#import <TTTAttributedLabel.h>
#import "URLHandler.h"
#import "DGAppearance.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer* userGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGoodUserProfile)];
    [self.user setUserInteractionEnabled:YES];
    [self.user addGestureRecognizer:userGesture];

    UITapGestureRecognizer* avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGoodUserProfile)];
    [self.avatar setUserInteractionEnabled:YES];
    [self.avatar addGestureRecognizer:avatarGesture];
    self.commentBody.linkAttributes = [DGAppearance linkAttributes];
    self.commentBody.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setValues {
    [self.avatar setImageWithURL:[NSURL URLWithString:self.comment.user.avatar]];
    self.user.text = self.comment.user.username;

    NSDictionary *attributes = @{ NSFontAttributeName : self.commentBody.font };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.comment.comment attributes:attributes];
    self.commentBody.attributedText = attrString;

    for (DGEntity *entity in self.comment.entities) {
        NSURL *url = [NSURL URLWithString:entity.link];
        [self.commentBody addLinkToURL:url withRange:[entity rangeFromArray]];
    }
}

#pragma mark - TTTAttributedLabel delegate methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    URLHandler *handler = [[URLHandler alloc] init];
    [handler openURL:url andReturn:^(BOOL matched) {
        return matched;
    }];
}

#pragma mark - User profile helper
- (void)showGoodUserProfile {
    [DGUser openProfilePage:self.comment.user.userID inController:self.navigationController];
}

@end
