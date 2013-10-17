#import "GoodShareCell.h"
#import "DGTwitterManager.h"
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
    [self.share addTarget:self action:@selector(checkTwitter) forControlEvents:UIControlEventValueChanged];
}

- (void)checkTwitter {
    DebugLog(@"twitter %d", self.share.on);
    if([self.share isOn]) {
        DebugLog(@"tweeting");
        [self.twitterManager checkTwitterPostAccessWithSuccess:^(NSString *msg) {
            DebugLog(@"success");
            self.share.on = YES;
        } failure:^(NSError *error) {
            self.share.on = NO;
            [self.twitterManager promptForPostAccess];
            DebugLog(@"failed to get access. prompt user.");
        }];
    } else {
        DebugLog(@"not tweeting");
    }
}

/*
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
*/

#pragma mark - Facebook methods
- (void)facebook {
    [self.share addTarget:self action:@selector(checkFacebook) forControlEvents:UIControlEventValueChanged];
}

- (void)checkFacebook {
    DebugLog(@"check facebook");
    if([self.share isOn]) {
        DebugLog(@"facebookin");
        [self.facebookManager checkFacebookPostAccessWithSuccess:^(BOOL success, NSString *msg) {
            DebugLog(@"success");
            self.share.on = YES;
        } failure:^(NSError *error) {
            self.share.on = NO;
            [self.facebookManager promptForPostAccess];
            DebugLog(@"failed to get access. prompt user.");
        }];
    } else {
        DebugLog(@"not facebookin, dont do anything");
    }
}

@end
