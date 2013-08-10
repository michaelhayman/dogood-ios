#import "GoodShareCell.h"

#define dogood_share_tag 501
#define facebook_share_tag 502
#define twitter_share_tag 503
@implementation GoodShareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    DebugLog(@"self share %@", self.share);
    self.share.on = NO;
    DebugLog(@"cell %d", self.tag);

    if (self.tag == facebook_share_tag) {
        [self.share addTarget:self action:@selector(checkFacebook) forControlEvents:UIControlEventValueChanged];
    } else if (self.tag == dogood_share_tag) {
        [self.share addTarget:self action:@selector(checkDoGood) forControlEvents:UIControlEventValueChanged];
    } else if (self.tag == twitter_share_tag) {
        [self.share addTarget:self action:@selector(checkTwitter) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Do Good
- (void)checkDoGood {
    DebugLog(@"do good");
}

- (void)doGood {
    [self.share addTarget:self action:@selector(checkDoGood) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Twitter
- (void)checkTwitter {
    DebugLog(@"twitter");
    DGUser *user = [DGUser currentUser];
}

/*
- (void)callTwitterAPI {
    NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
        NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    DebugLog(@"data %@", data);
}
*/
- (void)twitter {
    [self.share addTarget:self action:@selector(checkTwitter) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Facebook methods
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

- (void)facebook {
    [self.share addTarget:self action:@selector(checkFacebook) forControlEvents:UIControlEventValueChanged];
}

@end
