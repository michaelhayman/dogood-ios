#import "GoodCell.h"
#import "DGGood.h"
#import "DGCategory.h"
#import "DGReport.h"
#import "DGFollow.h"
#import "DGTag.h"
#import "DGEntity.h"
#import "DGGoodCommentsViewController.h"
#import "DGUserProfileViewController.h"
#import "DGUserListViewController.h"
#import "DGUserInvitesViewController.h"
#import "DGGoodListViewController.h"
#import "URLHandler.h"
#import "CommentCell.h"
#import "DGNominee.h"
#import "NSString+Inflections.h"
#import "NSString+RangeChecker.h"
#import <ProgressHUD/ProgressHUD.h>
#import "DGEventSaver.h"
#import "DGMapViewController.h"

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

    // image
    self.overviewImage.contentMode = UIViewContentModeScaleAspectFill;
    // UIViewContentModeScaleAspectFit;
    [self.overviewImage setClipsToBounds:YES];

    // votes
    [self.vote addTarget:self action:@selector(addUserVote) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer* votesGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showVoters)];
    [self.votesCount setUserInteractionEnabled:YES];
    [self.votesCount addGestureRecognizer:votesGesture];

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
    [self.follow addTarget:self action:@selector(followGood) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer* followersGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowers)];
    [self.followersCount setUserInteractionEnabled:YES];
    [self.followersCount addGestureRecognizer:followersGesture];

    // more options
    [self.moreOptions addTarget:self action:@selector(openMoreOptions) forControlEvents:UIControlEventTouchUpInside];

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
    [self setNominee];

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

    // votes
    if ([self.good.current_user_voted boolValue]) {
        [self.vote setSelected:YES];
    } else {
        [self.vote setSelected:NO];
    }
    [self setVotesText];

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
    if ([self.good.current_user_followed boolValue]) {
        [self.follow setSelected:YES];
    } else {
        [self.follow setSelected:NO];
    }
    [self setFollowsText];

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

- (void)setNominee {
    if (self.good.nominee) {
        self.nomineeHeight.constant = 21.0;
        self.nominee.text = [NSString stringWithFormat:@"Nominee: %@", self.good.nominee.full_name];
        if (self.good.nominee.user_id) {
            UITapGestureRecognizer* userGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGoodUserProfile)];
            [self.nominee setUserInteractionEnabled:YES];
            [self.nominee addGestureRecognizer:userGesture];

            self.nominee.textColor = LINK_COLOUR;
        } else {
            self.nominee.textColor = [UIColor blackColor];
            [self.nominee setUserInteractionEnabled:NO];
        }
    } else {
        self.nominee.text = @"Wanted:";
        self.nomineeHeight.constant = 0.0;
    }
}

- (void)setDoneImage {
    if ([self.good.done boolValue]) {
        self.done.hidden = YES;
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
    NSRange stringRange = NSMakeRange([[self.good postedByType] length], [self.good.user.full_name length]);

    if ([text containsRange:stringRange]) {
        [self.postedBy addLinkToURL:url withRange:stringRange];
    }
}

#pragma mark - Follows
- (void)followGood {
    if ([[DGUser currentUser] authorizeAccess:self.navigationController.visibleViewController]) {
        if (self.follow.isSelected == NO) {
            [self increaseFollows];

            [DGFollow followType:@"Good" withID:self.good.goodID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidChangeFollowOnGood object:nil];
                DebugLog(@"%@", msg);
            } failure:^(NSError *error) {
                [self decreaseFollows];
                DebugLog(@"failed to remove follow");
            }];
        } else {
            [self decreaseFollows];

            [DGFollow unfollowType:@"Good" withID:self.good.goodID inController:self.navigationController withSuccess:^(BOOL success, NSString *msg) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidChangeFollowOnGood object:nil];
                DebugLog(@"%@", msg);
            } failure:^(NSError *error) {
                [self increaseFollows];
                DebugLog(@"failed to remove follow");
            }];
        }
    }
}

- (void)increaseFollows {
    [self.follow setSelected:YES];
    self.good.followers_count = @(self.good.followers_count.intValue + 1);
    self.good.current_user_followed = [NSNumber numberWithBool:YES];
    [self setFollowsText];
    [self reloadCell];
}

- (void)decreaseFollows {
    [self.follow setSelected:NO];
    self.good.followers_count = @(self.good.followers_count.intValue - 1);
    self.good.current_user_followed = [NSNumber numberWithBool:NO];
    [self setFollowsText];
    [self reloadCell];
}

- (void)setFollowsText {
    if ([self.good.followers_count intValue] > 0) {
        followersHeight.constant = 21.0;

        NSString *follower = @"follower";

        if ([self.good.followers_count intValue] != 1) {
            follower = [follower pluralize];
        }
        self.followersCount.text = [NSString stringWithFormat:@"%@ %@", self.good.followers_count, follower];
    } else {
        followersHeight.constant = 0.0;
    }
}

- (void)showFollowers {
    [self userListWithType:@"Good" typeID:self.good.goodID andQuery:@"followers"];
}

#pragma mark - Votes
- (void)addUserVote {
    if ([[DGUser currentUser] authorizeAccess:self.navigationController.visibleViewController]) {
        NSString *type = @"Good";
        NSDictionary *voteDict = [NSDictionary dictionaryWithObjectsAndKeys:self.good.goodID, @"votable_id", type, @"votable_type", nil];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:voteDict, @"vote", nil];

        if (self.vote.isSelected == NO) {
            [self increaseVote];
            [[RKObjectManager sharedManager] postObject:nil path:@"/votes" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidChangeVoteOnGood object:nil];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                DebugLog(@"failed to add");
                [self decreaseVote];
                DebugLog(@"%@", [error userInfo]);
                [TSMessage showNotificationInViewController:self.navigationController
                                          title:nil
                                        subtitle:[error localizedDescription]
                                           type:TSMessageNotificationTypeError];
            }];
        } else {
            [self decreaseVote];
            [[RKObjectManager sharedManager] deleteObject:nil path:[NSString stringWithFormat:@"/votes/%@", self.good.goodID] parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidChangeVoteOnGood object:nil];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self increaseVote];
                DebugLog(@"%@", [error userInfo]);

                [TSMessage showNotificationInViewController:self.navigationController
                                          title:nil
                                        subtitle:[error localizedDescription]
                                           type:TSMessageNotificationTypeError];
            }];
        }
    }
}

- (void)increaseVote {
    [self.vote setSelected:YES];
    self.good.votes_count = @(self.good.votes_count.intValue + 1);
    self.good.current_user_voted = [NSNumber numberWithBool:YES];
    [self setVotesText];
    [self reloadCell];
}

- (void)decreaseVote {
    [self.vote setSelected:NO];
    self.good.votes_count = @(self.good.votes_count.intValue - 1);
    self.good.current_user_voted = [NSNumber numberWithBool:NO];
    [self setVotesText];
    [self reloadCell];
}

- (void)setVotesText {
    if ([self.good.votes_count intValue] > 0) {
        votesHeight.constant = 21.0;

        NSString *vote = @"vote";
        if ([self.good.votes_count intValue] != 1) {
            vote = [vote pluralize];
        }
        self.votesCount.text = [NSString stringWithFormat:@"%@ %@", self.good.votes_count, vote];
    } else {
        votesHeight.constant = 0.0;
    }
}

- (void)showVoters {
    [self userListWithType:@"Good" typeID:self.good.goodID andQuery:@"voters"];
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

        label.delegate = self;
        [comments addSubview:label];
    }
    commentBoxHeight.constant = lastHeight + 0.0;
    [self layoutIfNeeded];
}

#pragma mark - Description
- (void)setCaptionText {
    self.description.enabledTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypeDate | NSTextCheckingTypeAddress | NSTextCheckingTypePhoneNumber;
    self.description.text = self.good.caption;

    NSDictionary *attributes = @{NSFontAttributeName : self.description.font};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.good.caption attributes:attributes];
    self.description.attributedText = attrString;
    captionHeight.constant = [DGAppearance calculateHeightForText:attrString andWidth:kGoodRightColumnWidth];
    self.description.linkAttributes = [DGAppearance linkAttributes];
    self.description.activeLinkAttributes = [DGAppearance activeLinkAttributes];

    for (DGEntity *entity in self.good.entities) {
        NSURL *url = [NSURL URLWithString:entity.link];
        NSRange entityRange = [entity rangeFromArrayWithOffset:0];
        if ([self.good.caption containsRange:entityRange]) {
            [self.description addLinkToURL:url withRange:entityRange];
        }
    }

    self.description.delegate = self;
}

#pragma mark - More options
- (void)setupMoreOptions {
    NSString *destructiveTitle;
    if ([self.good isOwnGood]) {
        destructiveTitle = @"Delete post";
    } else {
        destructiveTitle = @"Report post";
    }
    moreOptionsSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:destructiveTitle
                                       otherButtonTitles:@"Share", nil];
    [moreOptionsSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    moreOptionsSheet.delegate = self;
    [self setupShareOptions];
}

- (void)openMoreOptions {
    [self setupMoreOptions];
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
                [self deleteOrReportGood];
            } else if (buttonIndex == share_button) {
                [self openShareOptions];
            }
        } else if (actionSheet == shareOptionsSheet) {
            NSString *text = [NSString stringWithFormat:@"Check out this good story! %@", [[self.good showURL] absoluteString]];
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
- (void)deleteOrReportGood {
    if ([[DGUser currentUser] authorizeAccess:self.parent]) {
        NSString *destructiveTitle;
        if ([self.good isOwnGood]) {
            destructiveTitle = @"You want to delete this post?";
        } else {
            destructiveTitle = @"You want to report this post?";
        }
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:destructiveTitle message:@"Are you sure?" delegate:self cancelButtonTitle:@"No..." otherButtonTitles:@"Yes!", nil];
        [alert show];
    }
}

- (void)confirmReportGood {
    if ([self.good isOwnGood]) {
        [self.good destroyGoodWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [ProgressHUD showSuccess:NSLocalizedString(@"Good deleted", nil)];
            } else {
                [TSMessage showNotificationInViewController:self.parent
                                          title:NSLocalizedString(@"Good not deleted.", nil)
                                       subtitle:[error localizedDescription]
                                           type:TSMessageNotificationTypeError];
            }
        }];
    } else {
        [DGReport fileReportFor:self.good.goodID ofType:@"good" inController:self.navigationController];
    }
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

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithDate:(NSDate *)date {
    DebugLog(@"selected a date");
    NSString *title = [NSString stringWithFormat:@"Do Good with %@", self.good.user.full_name];
    DGEventSaver *eventSaver = [[DGEventSaver alloc] init];
    [eventSaver createEventWithTitle:title notes:self.good.caption url:[self.good showURL] startDate:date duration:0 completion:^(NSString *eventIdentifier, NSError *error) {
        DebugLog(@"complete");
        if (error) {
            DebugLog(@"error %@", [error localizedDescription]);
            return;
        } else {
            DebugLog(@"success");
        }
    }];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    DebugLog(@"selected a phone number");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents {
    DebugLog(@"selected an address");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGMapViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"mapView"];
    [controller addSinglePinForAddress:addressComponents];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.parent presentViewController:nav animated:YES completion:nil];
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
