#import "DGNominee.h"

@implementation DGNominee

- (void)configureForUser:(DGUser *)user {
    self.full_name = user.full_name;
    self.email = user.email;
    self.user_id = user.userID;
    self.twitter_id = user.twitter_id;
    self.facebook_id = user.facebook_id;
}

- (NSString *)type {
    static NSString *type;
    if (self.user_id) {
        type = @"DG";
    } else if (self.email) {
        type = @"AB";
    } else if (self.twitter_id) {
        type = @"TWTR";
    } else if (self.facebook_id) {
        type = @"FB";
    }
    return type;
}

- (NSURL *)avatarURL {
    return [NSURL URLWithString:self.avatar];
}

@end
