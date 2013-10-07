@class DGComment;

@interface CommentCell : UITableViewCell {
}

@property (weak, nonatomic) DGComment *comment;
@property (weak, nonatomic) IBOutlet UILabel *commentBody;
@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) UINavigationController *navigationController;

- (void)setValues;

@end
