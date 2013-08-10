#import "DGUser.h"

@implementation DGUser

@dynamic username;

static DGUser* currentUser = nil;

+ (DGUser*)currentUser {
	return currentUser;
}

@end
