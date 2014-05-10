#import "DGNominee.h"
#import <SHEmailValidator/SHEmailValidator.h>

@implementation DGNominee

- (void)configureForUser:(DGUser *)user {
    self.full_name = user.full_name;
    self.email = user.email;
    self.user_id = user.userID;
    self.twitter_id = user.twitter_id;
    self.facebook_id = user.facebook_id;
}

- (BOOL)isDGUser {
   return [self.user_id intValue] > 0;
}

- (BOOL)isContactable {
    return [self hasValidEmail] || [self hasValidPhone];
}

- (BOOL)hasValidEmail {
    NSError *error = nil;
    [[SHEmailValidator validator] validateSyntaxOfEmailAddress:self.email withError:&error];

    if (!error) {
        return true;
    }
    return false;
}

- (BOOL)hasValidPhone {
    if (![self.phone isEqualToString:@""]) {
        return true;
    }
    return false;
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

- (BOOL)isPopulated {
    if (![self.full_name isEqualToString:@""]) {
        return true;
    } else {
        return false;
    }
}

@end
