#import "GoodCell.h"
#import "DGGood.h"
#import "DGCategory.h"
#import "DGVote.h"
#import "DGFollow.h"
#import "DGReport.h"
#import "DGTag.h"
#import "DGGoodCommentsViewController.h"
#import <TTTAttributedLabel.h>
#import "DGUserProfileViewController.h"
#import "DGUserListViewController.h"
#import "DGUserInvitesViewController.h"
#import "DGGoodListViewController.h"

#define kRightColumnWidth 236.0

static inline NSRegularExpression * NameRegularExpression() {
    static NSRegularExpression *_nameRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _nameRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"^\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _nameRegularExpression;
}

static inline  NSRegularExpression * HashRegularExpression()
{
    static NSRegularExpression *_HashRegularExpression = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _HashRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(?:^|\\s|[\\p{Punct}&&[^/]])(#[\\p{L}0-9-_]+)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return _HashRegularExpression;
}

static inline  NSRegularExpression * UserNameRegularExpression()
{
    static NSRegularExpression *_usernameRegularExpression = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _usernameRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(?:^|\\s|[\\p{Punct}&&[^/]])((#[\\p{L}0-9-_]+)|(@[\\p{L}0-9-_\\.]+))" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return _usernameRegularExpression;
}

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

    // description
    // self.description.contentInset = UIEdgeInsetsMake(-10,-4,0,-10);

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

    categoryImage.image = [UIImage imageNamed:@"CategoryIconOn"];
    locationImage.image = [UIImage imageNamed:@"LocationIconOn"];
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
    [comments.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    DebugLog(@"reusing");
}

#pragma mark - Set values when cell becomes visible
- (void)setupAvatar {
    if (self.good.user.avatar) {
        [self.avatar setImageWithURL:[NSURL URLWithString:self.good.user.avatar]];
        self.avatar.hidden = NO;
        self.avatarHeight.constant = 57;
        self.avatarHeightSpacing.constant = 8;
    } else {
        self.avatar.hidden = YES;
        self.avatarHeight.constant = 0;
        self.avatarHeightSpacing.constant = 0;
    }
}

- (void)setValues {
    // user
    self.username.text = self.good.user.username;
    [self setupAvatar];
    // description
    [self setCaptionText];
    // image
    [self.overviewImage setImageWithURL:[NSURL URLWithString:self.good.evidence]];

    if (self.good.evidence) {
        self.overviewImageHeight.constant = 302;
        self.overviewImage.hidden = NO;
    } else {
        self.overviewImageHeight.constant = 0;
        self.overviewImage.hidden = YES;
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

#pragma mark - Regoods
- (void)addUserRegood {
    DGFollow *regood = [DGFollow new];
    regood.followable_id = self.good.goodID;
    regood.followable_type = @"Good";

    if (self.regood.isSelected == NO) {
        [self increaseRegood];
        [[RKObjectManager sharedManager] postObject:regood path:@"/follows" parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"failed to add regood");
            [self decreaseRegood];
        }];
    } else {
        [self decreaseRegood];
        [[RKObjectManager sharedManager] postObject:regood path:@"/follows/remove" parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self increaseRegood];
            DebugLog(@"failed to remove regood");
        }];
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
        self.regoods.text = [NSString stringWithFormat:@"%@ regoods", self.good.regoods_count];
    } else {
        regoodsHeight.constant = 0.0;
    }
}

- (void)showRegooders {
    [self userListWithType:@"Good" typeID:self.good.goodID andQuery:@"followers"];
}

#pragma mark - Likes
- (void)addUserLike {
    DGVote *vote = [DGVote new];
    vote.voteable_id = self.good.goodID;
    vote.voteable_type = @"Good";

    if (self.like.isSelected == NO) {
        [self increaseLike];
        [[RKObjectManager sharedManager] postObject:vote path:@"/votes" parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"failed to add");
            [self decreaseLike];
        }];
    } else {
        [self decreaseLike];
        [[RKObjectManager sharedManager] postObject:vote path:@"/votes/remove" parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self increaseLike];
            DebugLog(@"failed to remove like");
        }];
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
        self.likes.text = [NSString stringWithFormat:@"%@ likes", self.good.likes_count];
    } else {
        likesHeight.constant = 0.0;
    }
}

- (void)showLikers {
    [self userListWithType:@"Good" typeID:self.good.goodID andQuery:@"likers"];
}

#pragma mark - Comments
- (void)addComment {
    UIStoryboard *goodS = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodCommentsViewController *commentsView = [goodS instantiateViewControllerWithIdentifier:@"GoodComments"];
    commentsView.good = self.good;
    commentsView.makeComment = YES;
    commentsView.goodCell = self;
    [self.navigationController pushViewController:commentsView animated:YES];
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
        self.commentsCount.text = [NSString stringWithFormat:@"%@ comments", self.good.comments_count];
    } else {
        commentsHeight.constant = 0.0;
    }
}

- (TTTAttributedLabel *)commentLabel {
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"Calibre" size:12];
    label.textColor = [UIColor darkGrayColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;

    label.linkAttributes = [self linkAttributes];
    return label;
}

- (NSDictionary *)linkAttributes {
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:LINK_COLOUR, [NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    return linkAttributes;
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
        NSString *text = [NSString stringWithFormat:@"%@ %@", comment.user.username, comment.comment];

        label.font = [UIFont systemFontOfSize:10];

        [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
            
            // NSRegularExpression *regexp = NameRegularExpression();

            NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@+",comment.user.username] options:NSRegularExpressionCaseInsensitive error:nil];

            [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {            
                UIFont *italicSystemFont = [UIFont boldSystemFontOfSize:10];
                CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)italicSystemFont.fontName, italicSystemFont.pointSize, NULL);
                if (italicFont) {
                    [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:result.range];
                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:result.range];
                    CFRelease(italicFont);
                    
                    [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:result.range];
                    [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[[UIColor grayColor] CGColor] range:result.range];
                }
            }];

            return mutableAttributedString;
        }];

        NSRange r = [text rangeOfString:comment.user.username];
        [label addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"dogood://users/%@", comment.user.userID]] withRange:r];

        CGFloat labelWidth = 221;
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
    NSDictionary *attributes = @{NSFontAttributeName : self.description.font};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.good.caption attributes:attributes];
    self.description.attributedText = attrString;
    captionHeight.constant = [GoodCell calculateHeightForText:attrString];
    self.description.linkAttributes = [self linkAttributes];

    NSRange stringRange = NSMakeRange(0, [self.description.attributedText length]);
    NSRegularExpression *regexp = HashRegularExpression();
    [regexp enumerateMatchesInString:[self.description.attributedText string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *noHashes = [[[self.description.attributedText string] substringWithRange:result.range] stringByReplacingOccurrencesOfString:@"#" withString:@""];
        NSString *noSpacesAndNoHashes = [noHashes stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *urlString = [NSString stringWithFormat:@"dogood://goods/tagged/%@", noSpacesAndNoHashes];
        NSURL *url = [NSURL URLWithString:urlString];
        // DebugLog(@"URL string %@ %@ %@", urlString, noSpacesAndNoHashes, noHashes, [url absoluteString]);
        [self.description addLinkToURL:url withRange:result.range];
    }];

    self.description.delegate = self;
}

+ (CGFloat)calculateHeightForText:(NSAttributedString *)string {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(kRightColumnWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGSize size = rect.size;
    CGFloat height = ceilf(size.height);
    // CGFloat width  = ceilf(size.width);

    return height;
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
    shareOptionsSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Text message", @"Email", nil];
                                           // otherButtonTitles:@"Text message", @"Email", @"Facebook", @"Twitter", nil];
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
                DebugLog(@"Share");
            }
        } else if (actionSheet == shareOptionsSheet) {
            NSString *text = [NSString stringWithFormat:@"Check out this good story! dogood://goods/%@", self.good.goodID];
            if (buttonIndex == text_message_button) {
                [invites setCustomText:text withSubject:nil];
                [invites sendViaText:nil];
                DebugLog(@"Text message");
            } else if (buttonIndex == email_button) {
                [invites setCustomText:text withSubject:@"Check out this good!"];
                [invites sendViaEmail:nil];
                DebugLog(@"Email");
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
    [DGUser openProfilePage:self.good.user.userID inController:self.navigationController];
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
    DebugLog(@"selected");
    if ([[url scheme] hasPrefix:@"dogood"]) {
        NSArray *urlComponents = [url pathComponents];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];

        if ([[url host] hasPrefix:@"users"]) {
            NSNumber * userID = [f numberFromString:urlComponents[1]];
            [DGUser openProfilePage:userID inController:self.navigationController];
        } else if ([[url host] hasPrefix:@"show-settings"]) {
            /* load settings screen */
        } else if ([[url host] hasPrefix:@"goods"]) {
            DGTag *tag = [DGTag new];
            tag.name = [url pathComponents][2];
            [self openTag:tag];
        } else {
            DebugLog(@"hit here");
        }
    } else {
        /* deal with http links here */
        DebugLog(@"not sure what else to do %@", [url scheme]);
    }
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
    UITableView *table = (UITableView *)self.superview.superview;
    NSIndexPath *indexPath = [table indexPathForCell:(UITableViewCell *)self];
    [self.parent reloadCellAtIndexPath:indexPath withGood:self.good];
}

@end
