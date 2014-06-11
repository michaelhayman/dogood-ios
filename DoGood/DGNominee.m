#import "DGNominee.h"
#import "DGGood.h"
#import <SHEmailValidator/SHEmailValidator.h>

@implementation DGNominee

- (void)configureForUser:(DGUser *)user {
    self.full_name = user.full_name;
    self.email = user.email;
    self.user_id = user.userID;
    self.twitter_id = user.twitter_id;
    self.facebook_id = user.facebook_id;
    self.avatar_url = user.avatar_url;
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
    return [NSURL URLWithString:self.avatar_url];
}

- (BOOL)isPopulated {
    if (![self.full_name isEqualToString:@""]) {
        return true;
    } else {
        return false;
    }
}

- (NSString *)inviteTextForPost:(DGGood *)good {
    NSString *body = [NSString stringWithFormat:@"<table align=center width=250 cellpadding=5px>\n"
      "<tr>\n"
      "<td bgcolor=\"#2BC823\" style=\"border-collapse: collapse\">\n"
      "    <img src=\"http://www.dogood.mobi/images/app_icons/app_icon_300x300.png\" alt=\"Do Good\" width=\"250\" height=\"250\">\n"
      "  </td>\n"
      "</tr>\n"
      "<tr>\n"
      "  <td style=\"border-collapse: collapse; text-align: center\">\n"
      "    <h2 style=\"font-family: 'Helvetica Neue', Arial; color: gray\">You've been nominated!</h2>\n"
      "  </td>\n"
      "</tr>\n"
      "<tr>\n"
      "  <td style=\"border-collapse: collapse\">\n"
      "    <span style=\"font-family: 'Helvetica Neue', Arial; color: gray;\">\n"
      "      %@ has nominated you for doing a good deed!"
      "      <p>Here's what they had to say about you, %@:</p>\n"
      "      <p><blockquote>%@</blockquote></p>\n"
      "      Download the app and see for yourself, plus:\n"
      "      <br>\n"
      "      <ul>\n"
      "        <li>Nominate and reward good deeds</li>\n"
      "        <li>Find good things to do near you</li>\n"
      "        <li>Get help for good projects</li>\n"
      "      </ul>\n"
      "      <p>\n"
      "        <center><a href=\"http://www.dogood.mobi\"><img src=\"http://www.dogood.mobi/images/app_stores/ios_app_store.png\" alt=\"Get for iOS\" id=\"appstore\" width=\"250\"></a></center>\n"
      "      </p>"
      "      <p>&nbsp;</p>"
      "      <p>&nbsp;</p>"
      "      <p>\n"
      "        <center>\n"
      "          <a href=\"http://www.dogood.mobi/\"><img src=\"http://www.dogood.mobi/images/logos/dg_logo_tiny_green.png\"></a>\n"
      "        </center>\n"
      "      </p>\n"
      "    </span>\n"
      "  </td>\n"
      "</tr>\n"
      "<tr>\n"
      "  <td style=\"border-collapse: collapse\">"
      "    <p>&nbsp;</p>"
      "    <font face=sans-serif size=2>"
      "      <center>"
      "        You have not been added to any email lists."
      "      </center>"
      "    </font>"
      "  </td>"
      "</tr>"
      "</table>",
      good.user.full_name, good.nominee.full_name, good.caption];
    return body;

}

@end
