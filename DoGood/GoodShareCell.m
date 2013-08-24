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

@end
