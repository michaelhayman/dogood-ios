#import "GoodShareCell.h"
#import "ThirdParties.h"
#import "DGFacebookManager.h"

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
        //DebugLog(@"no %d", self.share.selected);
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
    [self.share addTarget:self action:@selector(checkFacebook) forControlEvents:UIControlEventValueChanged];
}

- (void)checkFacebook {
    DebugLog(@"check facebook");
    if([self.share isOn]) {
        DebugLog(@"facebookin");
        [self.facebookManager checkFacebookPostAccessWithSuccess:^(NSString *msg) {
            DebugLog(@"success");
            self.share.on = YES;
        } failure:^(NSString *error) {
            self.share.on = NO;
            [self.facebookManager promptForPostAccess];
            DebugLog(@"failed to get access. prompt user.");
        }];
    } else {
        DebugLog(@"not facebookin, dont do anything");
    }
}

@end
