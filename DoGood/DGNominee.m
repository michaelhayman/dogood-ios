#import "DGNominee.h"

@implementation DGNominee

- (void)configureForUser:(DGUser *)user {
    self.fullName = user.full_name;
}

@end
