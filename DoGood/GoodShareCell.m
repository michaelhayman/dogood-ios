#import "GoodShareCell.h"
#import "ThirdParties.h"

#define share_do_good_cell_tag 501
#define share_facebook_cell_tag 502
#define share_twitter_cell_tag 503

@implementation GoodShareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.share.on = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidCheckIfTwitterIsConnected object:nil];
}

#pragma mark - Do Good
- (void)checkDoGood {
    DebugLog(@"do good");
}

- (void)doGood {
    [self.share addTarget:self action:@selector(checkDoGood) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Twitter
- (void)twitter {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterConnected:) name:DGUserDidCheckIfTwitterIsConnected object:nil];
    [self.share addTarget:self action:@selector(checkTwitter) forControlEvents:UIControlEventValueChanged];
}

- (void)checkTwitter {
    DebugLog(@"twitter %d", self.share.on);
    if([self.share isOn]) {
        DebugLog(@"tweeting");
        [ThirdParties checkTwitterAccess:YES];
    } else {
        DebugLog(@"not tweeting");
    }
}

- (void)twitterConnected:(NSNotification *)notification {
    DebugLog(@"twitter connected?");
    NSNumber* connected = [[notification userInfo] objectForKey:@"connected"];
    if ([connected boolValue]) {
        // [self.share performSelectorOnMainThread:@selector(setOn:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(shareOn) withObject:nil waitUntilDone:NO];
        DebugLog(@"yes");
    } else {
        // [self.share performSelectorOnMainThread:@selector(setOn:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(shareOff) withObject:nil waitUntilDone:NO];
        DebugLog(@"no %d", self.share.selected);
    }
}

- (void)shareOn {
    // [self.share setOn:YES];
    UISwitch *shareTwitter = (UISwitch *)[[self contentView] viewWithTag:share_twitter_cell_tag];
    [shareTwitter setOn:YES animated:YES];
    UISwitch *shareFacebook = (UISwitch *)[[self contentView] viewWithTag:share_facebook_cell_tag];
    [shareFacebook setOn:YES animated:YES];
}

- (void)shareOff {
    UISwitch *shareTwitter = (UISwitch *)[[self contentView] viewWithTag:share_twitter_cell_tag];
    [shareTwitter setOn:NO animated:YES];
    UISwitch *shareFacebook = (UISwitch *)[[self contentView] viewWithTag:share_facebook_cell_tag];
    [shareFacebook setOn:NO animated:YES];
}

#pragma mark - Facebook methods
- (void)facebook {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookConnected:) name:DGUserDidCheckIfFacebookIsConnectedAndHasPermissions object:nil];
    [self.share addTarget:self action:@selector(checkFacebook) forControlEvents:UIControlEventValueChanged];
}

- (void)checkFacebook {
    DebugLog(@"facebook %d", self.share.on);
    if([self.share isOn]) {
        DebugLog(@"facebooking");
        [ThirdParties checkFacebookAccessForPosting];
    } else {
        DebugLog(@"not facebookin, dont do anything");
    }
}

- (void)facebookConnected:(NSNotification *)notification {
    DebugLog(@"facebook connected?");
    NSNumber* permission = [[notification userInfo] objectForKey:@"permission"];
    if ([permission boolValue]) {
        // [self.share performSelectorOnMainThread:@selector(setOn:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(shareOn) withObject:nil waitUntilDone:NO];
        DebugLog(@"yes");
    } else {
        // [self.share performSelectorOnMainThread:@selector(setOn:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(shareOff) withObject:nil waitUntilDone:NO];
        DebugLog(@"no %d", self.share.selected);
    }
}

/*
- (void)checkFacebook {
    if (self.share.on != NO) {
        DebugLog(@"Trying to check the box");
        DGUser *user = [DGUser currentUser];
        if (![PFFacebookUtils isLinkedWithUser:user]) {
            DebugLog(@"Not linked with a user");
            NSArray *permissions = @[@"publish_actions"];
            [PFFacebookUtils linkUser:user permissions:permissions block:^(BOOL succeeded, NSError *error) {
                self.share.on = NO;
                if (succeeded && !error) {
                    [self checkFacebookPublishPermissionWithBlock:^(BOOL canShare, NSError *error) {
                        self.share.on = canShare;
                    }];
                } else {
                    self.share.on = NO;
                }
            }];
        } else {
            DebugLog(@"Linked with a user");
            [self checkFacebookPublishPermissionWithBlock:^(BOOL canShare, NSError *error) {
                if (canShare) {
                   DebugLog(@"And have permission");
                    self.share.on = YES;
                } else {
                   DebugLog(@"Without permission");
                    // re-authorize permission here
                    [PFFacebookUtils reauthorizeUser:[PFUser currentUser] withPublishPermissions:@[@"publish_actions"] audience:FBSessionDefaultAudienceFriends block:^(BOOL succeeded, NSError *error) {
                        self.share.on = NO;
                        if (succeeded) {
                            [self checkFacebookPublishPermissionWithBlock:^(BOOL canShare, NSError *error) {
                                self.share.on = canShare;
                            }];
                       } else {
                           DebugLog(@"should be hit...");
                           self.share.on = NO;
                       }
                   }];
               }
            }];
        }
    } else {
        DebugLog(@"share off");
    }
}
*/

/*
- (void)checkFacebookPublishPermissionWithBlock:(void (^)(BOOL canShare, NSError *error))completionBlock {
    NSString *permissionsString = @"publish_actions";
    DebugLog(@"inside here");
    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
            DebugLog(@"no error %@", result);
             NSDictionary *data = [[result objectForKey:@"data"] objectAtIndex:0];
            DebugLog(@"data %@", data);
             BOOL canSharePost;

             if ([[data objectForKey:permissionsString] integerValue] == NSNotFound ||
                 [[data objectForKey:permissionsString]integerValue] == 0) {
                 canSharePost = NO;
                 if (completionBlock){
                     completionBlock(canSharePost, error);
                 }
             } else {
                 canSharePost = YES;
                 if (completionBlock){
                     completionBlock(canSharePost,error);
                 }
             }
             //NSLog(@"_can_share %d",canSharePost);
         } else {
            DebugLog(@"error %@", [error description]);
         }
    }];
}
*/

@end
