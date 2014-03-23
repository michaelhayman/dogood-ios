#import "GoodCell.h"
#import "DGGood.h"
#import "DGCategory.h"
#import "DGReport.h"
#import "DGFollow.h"
#import "DGTag.h"
#import "DGEntity.h"
#import "DGGoodCommentsViewController.h"
#import <TTTAttributedLabel.h>
#import "DGUserProfileViewController.h"
#import "DGUserListViewController.h"
#import "DGUserInvitesViewController.h"
#import "DGGoodListViewController.h"
#import "URLHandler.h"
#import "DGAppearance.h"
#import "CommentCell.h"
#import "DGNominee.h"
#import "TTTAttributedLabel+Tag.h"
#import "NSString+Inflections.h"

@implementation GoodCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // user
    self.avatar.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer* userAvatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGoodUserProfile)];
    [self.avatar setUserInteractionEnabled:YES];
    [self.avatar addGestureRecognizer:userAvatarGesture];

    UITapGestureRecognizer* userGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGoodUserProfile)];
    [self.username setUserInteractionEnabled:YES];
    [self.username addGestureRecognizer:userGesture];
    self.username.textColor = LINK_COLOUR;

    // image
    self.overviewImage.contentMode = UIViewContentModeScaleAspectFill;
    // UIViewContentModeScaleAspectFit;
    [self.overviewImage setClipsToBounds:YES];

    // likes
    [self.like addTarget:self action:@selector(addUserLike) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer* likesGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLikers)];
    [self.likes setUserInteractionEnabled:YES];
    [self.likes addGestureRecognizer:likesGesture];

    // categories
    UITapGestureRecognizer* openCategoryGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCategory)];
    [categoryTitle setUserInteractionEnabled:YES];
    [categoryTitle addGestureRecognizer:openCategoryGesture];

    UITapGestureRecognizer* imageOpenCategoryGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCategory)];
    [categoryImage setUserInteractionEnabled:YES];
    [categoryImage addGestureRecognizer:imageOpenCategoryGesture];

    // comments
    [self.comment addTarget:self action:@selector(addComment) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer* commentsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showComments)];
    [self.commentsCount setUserInteractionEnabled:YES];
    [self.commentsCount addGestureRecognizer:commentsGesture];
    commentBoxHeight.constant = 0;

    // re-goods
    [self.regood addTarget:self action:@selector(addUserRegood) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer* regoodsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRegooders)];
    [self.regoods setUserInteractionEnabled:YES];
    [self.regoods addGestureRecognizer:regoodsGesture];

    // more options
    [self.moreOptions addTarget:self action:@selector(openMoreOptions) forControlEvents:UIControlEventTouchUpInside];
    [self setupMoreOptions];

    locationImage.image = [UIImage imageNamed:@"icon_content_pin"];
}

- (void)dealloc {
    DebugLog(@"umm");
}

- (void)showLocation {
    locationImageHeight.constant = 20;
    locationImage.hidden = NO;
    locationTitle.hidden = NO;
}

- (void)hideLocation {
    locationImageHeight.constant = 0;
    locationImage.hidden = YES;
    locationTitle.hidden = YES;
}

- (void)showCategory {
    categoryImageHeight.constant = 20;
    categoryImage.hidden = NO;
    categoryTitle.hidden = NO;
}

- (void)hideCategory {
    categoryImageHeight.constant = 0;
    categoryImage.hidden = YES;
    categoryTitle.hidden = YES;
}

#pragma mark - Set up cell for reuse
- (void)prepareForReuse {
    [super prepareForReuse];
    self.description.attributedText = nil;
    [comments.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - Set values when cell becomes visible
- (void)setupAvatar {
    self.avatar.hidden = YES;
    self.avatarHeight.constant = 0;
    self.avatarHeightSpacing.constant = 0;

    if ([self.good.nominee avatarURL]) {
        [self.avatar setImageWithURL:[self.good.nominee avatarURL]];
        self.avatar.hidden = NO;
        self.avatarHeight.constant = 57;
        self.avatarHeightSpacing.constant = 8;
    }
}

- (void)setValues {
    // user
    self.username.text = self.good.nominee.full_name;
    [self setupAvatar];
    // description
    [self setCaptionText];

    [self setPostedByText];

    self.overviewImageHeight.constant = 0;
    self.overviewImage.hidden = YES;

    if ([self.good evidenceURL]) {
        [self.overviewImage setImageWithURL:[self.good evidenceURL]];
        self.overviewImageHeight.constant = 302;
        self.overviewImage.hidden = NO;
    }

    // likes
    if ([self.good.current_user_liked boolValue]) {
        [self.like setSelected:YES];
    } else {
        [self.like setSelected:NO];
    }
    [self setLikesText];

    // comments
    if ([self.good.current_user_commented boolValue]) {
        [self.comment setSelected:YES];
    } else {
        [self.comment setSelected:NO];
    }
    [self setCommentsText];

    // comments list
    [self setupCommentsList];
    // regoods
    if ([self.good.current_user_regooded boolValue]) {
        [self.regood setSelected:YES];
    } else {
        [self.regood setSelected:NO];
    }
    [self setRegoodsText];

    [self setDoneImage];

    // more options
    invites = [[DGUserInvitesViewController alloc] init];
    invites.parent = (UIViewController *)self.parent;

    if (self.good.category) {
        categoryTitle.text = self.good.category.name;
        [self showCategory];
        categoryImage.image = [self.good.category contentIcon];
    } else {
        categoryTitle.text = nil;
        [self hideCategory];
    }

    if (self.good.location_name) {
        locationTitle.text = self.good.location_name;
        [self showLocation];
    } else {
        locationTitle.text = nil;
        [self hideLocation];
    }
}

- (void)setDoneImage {
    if ([self.good.done boolValue] == NO) {
        self.done.image = [UIImage imageNamed:@"ToDoGood"];
        self.done.hidden = NO;
    } else {
        self.done.hidden = YES;
    }
}

#pragma mark - PostedBy
- (void)setPostedByText {
    NSDictionary *attributes = @{ NSFontAttributeName : self.postedBy.font };
    NSString *text = [self.good postedByLine];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    self.postedBy.attributedText = attrString;
    postedByHeight.constant = [DGAppearance calculateHeightForText:attrString andWidth:kGoodRightColumnWidth];
    self.postedBy.linkAttributes = [DGAppearance linkAttributes];
    self.postedBy.activeLinkAttributes = [DGAppearance activeLinkAttributes];
    self.postedBy.delegate = self;

    NSString *urlString = [NSString stringWithFormat:@"dogood://users/%@", self.good.user.userID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSRange stringRange = NSMakeRange(13, [self.good.user.full_name length]);
    [self.postedBy addLinkToURL:url withRange:stringRange];
}

#pragma mark - Regoods
- (void)addUserRegood {
    if ([[DGUser currentUser] authorizeAccess:self.navigationController.visibleViewController]) {
        if (self.regood.isSelected == NO) {
            [self increaseRegood];

            [DGFollow followType:@"Good" withID:self.good.goodID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
                DebugLog(@"%@", msg);
            } failure:^(NSError *error) {
                [self decreaseRegood];
                DebugLog(@"failed to remove follow");
            }];
        } else {
            [self decreaseRegood];

            [DGFollow unfollowType:@"Good" withID:self.good.goodID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
                DebugLog(@"%@", msg);
            } failure:^(NSError *error) {
                [self increaseRegood];
                DebugLog(@"failed to remove follow");
            }];
        }
    }
}

- (void)increaseRegood {
    [self.regood setSelected:YES];
    self.good.regoods_count = @(self.good.regoods_count.intValue + 1);
    self.good.current_user_regooded = [NSNumber numberWithBool:YES];
    [self setRegoodsText];
    [self reloadCell];
}

- (void)decreaseRegood {
    [self.regood setSelected:NO];
    self.good.regoods_count = @(self.good.regoods_count.intValue - 1);
    self.good.current_user_regooded = [NSNumber numberWithBool:NO];
    [self setRegoodsText];
    [self reloadCell];
}

- (void)setRegoodsText {
    if ([self.good.regoods_count intValue] > 0) {
        regoodsHeight.constant = 21.0;

        NSString *follower = @"follower";

        if ([self.good.regoods_count intValue] != 1) {
            follower = [follower pluralize];
        }
        self.regoods.text = [NSString stringWithFormat:@"%@ %@", self.good.regoods_count, follower];
    } else {
        regoodsHeight.constant = 0.0;
    }
}

- (void)showRegooders {
    [self userListWithType:@"Good" typeID:self.good.goodID andQuery:@"followers"];
}

#pragma mark - Likes
- (void)addUserLike {
    if ([[DGUser currentUser] authorizeAccess:self.navigationController.visibleViewController]) {
        NSString *type = @"Good";
        NSDictionary *voteDict = [NSDictionary dictionaryWithObjectsAndKeys:self.good.goodID, @"votable_id", type, @"votable_type", nil];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:voteDict, @"vote", nil];

        if (self.like.isSelected == NO) {
            [self increaseLike];
            [[RKObjectManager sharedManager] postObject:nil path:@"/votes" parameters:params success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
                DebugLog(@"failed to add");
                [self decreaseLike];
                DebugLog(@"%@", [error userInfo]);
                [TSMessage showNotificationInViewController:self.navigationController
                                          title:nil
                                        subtitle:[error localizedDescription]
                                           type:TSMessageNotificationTypeError];
            }];
        } else {
            [self decreaseLike];
            [[RKObjectManager sharedManager] deleteObject:nil path:[NSString stringWithFormat:@"/votes/%@", self.good.goodID] parameters:params success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self increaseLike];
                DebugLog(@"%@", [error userInfo]);

                [TSMessage showNotificationInViewController:self.navigationController
                                          title:nil
                                        subtitle:[error localizedDescription]
                                           type:TSMessageNotificationTypeError];
            }];
        }
    }
}

- (void)increaseLike {
    [self.like setSelected:YES];
    self.good.likes_count = @(self.good.likes_count.intValue + 1);
    self.good.current_user_liked = [NSNumber numberWithBool:YES];
    [self setLikesText];
    [self reloadCell];
}

- (void)decreaseLike {
    [self.like setSelected:NO];
    self.good.likes_count = @(self.good.likes_count.intValue - 1);
    self.good.current_user_liked = [NSNumber numberWithBool:NO];
    [self setLikesText];
    [self reloadCell];
}

- (void)setLikesText {
    if ([self.good.likes_count intValue] > 0) {
        likesHeight.constant = 21.0;

        NSString *vote = @"vote";
        if ([self.good.likes_count intValue] != 1) {
            vote = [vote pluralize];
        }
        self.likes.text = [NSString stringWithFormat:@"%@ %@", self.good.likes_count, vote];
    } else {
        likesHeight.constant = 0.0;
    }
}

- (void)showLikers {
    [self userListWithType:@"Good" typeID:self.good.goodID andQuery:@"likers"];
}

#pragma mark - Comments
- (void)addComment {
    if ([[DGUser currentUser] authorizeAccess:self.navigationController.visibleViewController]) {
        UIStoryboard *goodS = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
        DGGoodCommentsViewController *commentsView = [goodS instantiateViewControllerWithIdentifier:@"GoodComments"];
        commentsView.good = self.good;
        commentsView.makeComment = YES;
        commentsView.goodCell = self;
        [self.navigationController pushViewController:commentsView animated:YES];
    }
}

- (void)showComments {
    UIStoryboard *goodS = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodCommentsViewController *commentsView = [goodS instantiateViewControllerWithIdentifier:@"GoodComments"];
    commentsView.good = self.good;
    commentsView.goodCell = self;
    [self.navigationController pushViewController:commentsView animated:YES];
}

- (void)setCommentsText {
    if ([self.good.comments_count intValue] > 0) {
        commentsHeight.constant = 21.0;
        NSString *comment = @"comment";

        if ([self.good.comments_count intValue] != 1) {
            comment = [comment pluralize];
        }
        self.commentsCount.text = [NSString stringWithFormat:@"%@ %@", self.good.comments_count, comment];
    } else {
        commentsHeight.constant = 0.0;
    }
}

- (TTTAttributedLabel *)commentLabel {
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    label.font = kSummaryCommentFont;
    label.textColor = [UIColor darkGrayColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;

    label.linkAttributes = [DGAppearance linkAttributes];
    label.activeLinkAttributes = [DGAppearance activeLinkAttributes];
    return label;
}

- (void)setupCommentsList {
    CGFloat lastHeight = 0.0;
    if ([self.good.comments count] == 0) {
        commentBoxHeight.constant = 0;
        // self.comments.hidden = YES;
        return;
    }
    for (DGComment *comment in [self.good.comments reverseObjectEnumerator]) {
        TTTAttributedLabel *label = [self commentLabel];
        NSString *text = [comment commentWithUsername];

        label.font = kSummaryCommentFont;

        UIFont *font = [UIFont boldSystemFontOfSize:10];
        [CommentCell addUsernameAndLinksToComment:comment withText:text andFont:font inLabel:label];

        CGFloat labelWidth = kSummaryCommentRightColumnWidth;
        CGRect rect = [label.attributedText boundingRectWithSize:CGSizeMake(labelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGSize size = rect.size;
        CGFloat height = ceilf(size.height);
        CGFloat width  = ceilf(size.width);
        label.frame = CGRectMake(0, lastHeight, width, height);
        lastHeight = lastHeight + size.height;

        [label hashIfy:label.attributedText inLabel:label];
        label.delegate = self;
        [comments addSubview:label];
    }
    commentBoxHeight.constant = lastHeight + 0.0;
    [self layoutIfNeeded];
}

#pragma mark - Description
- (void)setCaptionText {
    NSDictionary *attributes = @{NSFontAttributeName : self.description.font};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.good.caption attributes:attributes];
    self.description.attributedText = attrString;
    captionHeight.constant = [DGAppearance calculateHeightForText:attrString andWidth:kGoodRightColumnWidth];
    self.description.linkAttributes = [DGAppearance linkAttributes];
    self.description.activeLinkAttributes = [DGAppearance activeLinkAttributes];

    [self.description hashIfy:self.description.attributedText inLabel:self.description];

    // duplicate hashing here
    for (DGEntity *entity in self.good.entities) {
        NSURL *url = [NSURL URLWithString:entity.link];
        [self.description addLinkToURL:url withRange:[entity rangeFromArrayWithOffset:0]];
    }

    self.description.delegate = self;
}

#pragma mark - More options
- (void)setupMoreOptions {
    moreOptionsSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Report post"
                                       otherButtonTitles:@"Share", nil];
    [moreOptionsSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    moreOptionsSheet.delegate = self;
    [self setupShareOptions];
}

- (void)openMoreOptions {
    [moreOptionsSheet showInView:self.navigationController.view];
}

#pragma mark - Share options
- (void)setupShareOptions {
    shareOptionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Text message", @"Email", nil]; // otherButtonTitles:@"Text message", @"Email", @"Facebook", @"Twitter", nil];
    [shareOptionsSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    shareOptionsSheet.delegate = self;
}

- (void)openShareOptions {
    [shareOptionsSheet showInView:self.navigationController.view];
}

#define share_button 1
#define text_message_button 0
#define email_button 1
#define facebook_button 2
#define twitter_button 3
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet == moreOptionsSheet) {
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [self reportGood];
            } else if (buttonIndex == share_button) {
                [self openShareOptions];
            }
        } else if (actionSheet == shareOptionsSheet) {
            NSString *text = [NSString stringWithFormat:@"Check out this good story! dogood://goods/%@", self.good.goodID];
            if (buttonIndex == text_message_button) {
                [invites setCustomText:text withSubject:nil];
                [invites sendViaText:nil];
            } else if (buttonIndex == email_button) {
                [invites setCustomText:text withSubject:@"Check out this good!"];
                [invites sendViaEmail:nil];
            } else if (buttonIndex == facebook_button) {
                DebugLog(@"Facebook");
            } else if (buttonIndex == twitter_button) {
                DebugLog(@"Twitter");
            }
        }
    }
}

#pragma mark - Report good
- (void)reportGood {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You want to report this post?"
                                                    message:@"Are you sure?"
                                                   delegate:self
                                          cancelButtonTitle:@"No..."
                                          otherButtonTitles:@"Yes!", nil];
    [alert show];
}

- (void)confirmReportGood {
    [DGReport fileReportFor:self.good.goodID ofType:@"good" inController:self.navigationController];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self confirmReportGood];
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

#pragma mark - User profile helper
- (void)showGoodUserProfile {
    [DGUser openProfilePage:self.good.nominee.user_id inController:self.navigationController];
}

#pragma mark - User list helper
- (void)userListWithType:(NSString *)type typeID:(NSNumber *)typeID andQuery:(NSString *)query {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserList"];
    controller.typeID = typeID;
    controller.type = type;
    controller.query = query;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - TTTAttributedLabel delegate methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    URLHandler *handler = [[URLHandler alloc] init];
    [handler openURL:url andReturn:^(BOOL matched) {
        if (matched) {
            DebugLog(@"yup");
        }
        return matched;
    }];
}

- (void)openTag:(DGTag *)tag {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    controller.tag = tag;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)openCategory {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    controller.category = self.good.category;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Utility functions
- (void)reloadCell {
    // UITableView *table = (UITableView *)self.superview.superview;
    // NSIndexPath *indexPath = [table indexPathForCell:(UITableViewCell *)self];
    // [self.parent reloadCellAtIndexPath:indexPath withGood:self.good];
}

@end
