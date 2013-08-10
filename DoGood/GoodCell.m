#import "GoodCell.h"
#import "DGGood.h"
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

    if ([self.good.current_user_liked boolValue]) {
        self.like.highlighted = YES;
        [self.like setTitle:@"v" forState:UIControlStateNormal];
    }
    [self.like addTarget:self action:@selector(addUserLike) forControlEvents:UIControlEventTouchUpInside];
    [self.regood addTarget:self action:@selector(addUserRegood) forControlEvents:UIControlEventTouchUpInside];
    [self.moreOptions addTarget:self action:@selector(openMoreOptions) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer* commentsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showComments)];
    [self.commentsCount setUserInteractionEnabled:YES];
    [self.commentsCount addGestureRecognizer:commentsGesture];

    moreOptionsSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Share", @"Report post", nil];
    [moreOptionsSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    moreOptionsSheet.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)addUserRegood {
    DebugLog(@"add user regood");
}

- (void)openMoreOptions {
    DebugLog(@"open more options");
    [moreOptionsSheet showInView:self.navigationController.view];
}

#define remove_button 0
#define select_new_button 1
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet == moreOptionsSheet) {
            DebugLog(@"button index %d", buttonIndex);
            if (buttonIndex == remove_button) {
                DebugLog(@"remove");
                self.good.category = nil;
            } else if (buttonIndex == select_new_button) {
                DebugLog(@"select new");
            }
        }
    } else {
        DebugLog(@"button index %d, %d", buttonIndex, actionSheet.cancelButtonIndex);
        // [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
    }
}

- (void)addUserLike {
    // maybe it's not working because it's not a pfobject
    // PFObject object
    // this should work according to the docs.
    DGUser *user = [DGUser currentUser];
    // PFUser *user = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[[PFUser currentUser] objectId]];
    // NSArray *array = [[NSArray alloc] initWithObjects:user, nil];
    // DebugLog(@"add like? %@, %@", [PFUser currentUser], user);
    if (![self.like isHighlighted]) {
        DebugLog(@"add like");
        // [self.good addUniqueObjectsFromArray:array forKey:@"likesByUser"];
        // [self.good addUniqueObject:user forKey:@"likesByUser"];
        self.like.highlighted = YES;
    } else {
        DebugLog(@"remove like");
    }
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
