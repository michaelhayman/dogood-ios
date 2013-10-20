#import "GoodShareCell.h"
#import "DGTwitterManager.h"
#import "DGFacebookManager.h"

@implementation GoodShareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.share.on = NO;
    self.share.onTintColor = COLOUR_GREEN;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Do Good
- (void)checkDoGood {
}

- (void)doGood {
    _type.text = @"Make private?";
    [self.share addTarget:self action:@selector(checkDoGood) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Twitter
- (void)twitter {
    _type.text = @"Share on Twitter";
    [self.share addTarget:self action:@selector(checkTwitter) forControlEvents:UIControlEventValueChanged];
}

- (void)checkTwitter {
    if([self.share isOn]) {
        [self.twitterManager checkTwitterPostAccessWithSuccess:^(BOOL success, NSString *msg) {
            self.share.on = YES;
        } failure:^(NSError *error) {
            self.share.on = NO;
            [self.twitterManager promptForPostAccess];
        }];
    }
}

#pragma mark - Facebook methods
- (void)facebook {
    _type.text = @"Share on Facebook";
    [self.share addTarget:self action:@selector(checkFacebook) forControlEvents:UIControlEventValueChanged];
}

- (void)checkFacebook {
    if([self.share isOn]) {
        [self.facebookManager checkFacebookPostAccessWithSuccess:^(BOOL success, NSString *msg) {
            self.share.on = YES;
        } failure:^(NSError *error) {
            self.share.on = NO;
            [self.facebookManager promptForPostAccess];
        }];
    }
}

@end
