@class DGGood;
@class DGGoodListViewController;
#import <TTTAttributedLabel.h>

@class DGUserInvitesViewController;

@interface GoodCell : UITableViewCell <UIActionSheetDelegate, TTTAttributedLabelDelegate, UIAlertViewDelegate> {
    UIActionSheet *moreOptionsSheet;
    UIActionSheet *shareOptionsSheet;
    
    __weak IBOutlet NSLayoutConstraint *captionHeight;
    
    __weak IBOutlet NSLayoutConstraint *captionWidth;
    __weak IBOutlet NSLayoutConstraint *commentBoxHeight;
    __weak IBOutlet NSLayoutConstraint *commentsHeight;
    __weak IBOutlet NSLayoutConstraint *followersHeight;
    __weak IBOutlet NSLayoutConstraint *votesHeight;
    __weak IBOutlet NSLayoutConstraint *postedByHeight;
    __weak IBOutlet UIView *comments;

    // location
    __weak IBOutlet UIImageView *locationImage;
    __weak IBOutlet NSLayoutConstraint *locationImageHeight;
    __weak IBOutlet UILabel *locationTitle;

    // category
    __weak IBOutlet UIImageView *categoryImage;
    __weak IBOutlet NSLayoutConstraint *categoryImageHeight;
    __weak IBOutlet UILabel *categoryTitle;

    DGUserInvitesViewController *invites;
}

@property (weak, nonatomic) NSLayoutConstraint *overviewImageHeight;

@property (weak, nonatomic) IBOutlet UIImageView *overviewImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;

@property (weak, nonatomic) IBOutlet UILabel *votesCount;

// avatar
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarHeightSpacing;

@property (weak, nonatomic) IBOutlet UILabel *nominee;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nomineeHeight;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *postedBy;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *formattedCaption;
@property (weak, nonatomic) IBOutlet UIButton *vote;
@property (weak, nonatomic) IBOutlet UIButton *comment;
@property (weak, nonatomic) IBOutlet UIButton *follow;
@property (weak, nonatomic) IBOutlet UIButton *moreOptions;
@property (weak, nonatomic) DGGood *good;
@property (weak, nonatomic) UIViewController *parent;
@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) IBOutlet UIImageView *done;


- (void)setValues;
- (void)reloadCell;

@end
