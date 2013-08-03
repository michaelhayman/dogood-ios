#import "GoodCell.h"
#import "DGGoodCommentsViewController.h"

@implementation GoodCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.avatar.contentMode = UIViewContentModeScaleAspectFit;
    // self.overviewImage.contentMode = UIViewContentModeScaleAspectFit;
    self.overviewImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.overviewImage setClipsToBounds:YES];
    [self.comment addTarget:self action:@selector(addComment) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer* commentsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showComments)];
    [self.commentsCount setUserInteractionEnabled:YES];
    [self.commentsCount addGestureRecognizer:commentsGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)addComment {
    DebugLog(@"adding comment");
    // UIButton *commentButton = (UIButton *)sender;

    UIStoryboard *goodS = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodCommentsViewController *comments = [goodS instantiateViewControllerWithIdentifier:@"GoodComments"];
    comments.good = self.good;
    DebugLog(@"comments good %@", comments.good);
    comments.makeComment = YES;
    [self.navigationController pushViewController:comments animated:YES];
}

-(void)showComments {
    DebugLog(@"adding comment");
    UIStoryboard *goodS = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodCommentsViewController *comments = [goodS instantiateViewControllerWithIdentifier:@"GoodComments"];
    comments.good = self.good;
    [self.navigationController pushViewController:comments animated:YES];
}

@end
