#import "DGUser.h"
#import "DGError.h"
#import "RFKeychain.h"

// Current User singleton
static DGUser* currentUser = nil;

@implementation DGUser

#pragma mark - Class methods
/**
 * Returns the singleton current User instance. There is always a User returned so that you
 * are not sending messages to nil
 */
+ (DGUser*)currentUser {
	if (nil == currentUser) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		id userID = [defaults objectForKey:kDGUserCurrentUserIDDefaultsKey];
		if (userID) {
			currentUser = [[self alloc] init];
            currentUser.userID = userID;
            currentUser.username = [defaults objectForKey:kDGUserCurrentUserUsername];
            currentUser.full_name = [defaults objectForKey:kDGUserCurrentUserFullName];
            currentUser.phone = [defaults objectForKey:kDGUserCurrentUserPhone];
            currentUser.email = [defaults objectForKey:kDGUserCurrentUserEmail];
            currentUser.contactable = [defaults objectForKey:kDGUserCurrentUserContactable];
            currentUser.password = [RFKeychain passwordForAccount:kDoGoodAccount service:kDoGoodService];
		} else {
            currentUser = [[self alloc] init];
		}
	}
	return currentUser;
}

+ (void)setCurrentUser:(DGUser*)user {
	currentUser = user;
}

#pragma mark - Sign In
+ (void)setAuthorizationHeader {
    DebugLog(@"setting authorization header for %@ and %@", currentUser.username, currentUser.password);
    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:currentUser.username password:currentUser.password];
}

+ (void)verifySavedUser {
    DebugLog(@"verify %@ %@", currentUser, currentUser.userID);
    if ([currentUser isSignedIn]) {
        DebugLog(@"is signed in");
        [[RKObjectManager sharedManager] postObject:self path:user_session_path parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"failed post to user session");
            if ([currentUser isSignedIn]) {
                DebugLog(@"signing out");
                [[DGUser currentUser] signOutWithMessage:NO];
            }
        }];
    }
}

+ (void)signInWasSuccessful {
    [self assignDefaults];

    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:currentUser.username password:currentUser.password];

	[[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSignInNotification object:self];
}

+ (void) assignDefaults {
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.userID forKey:kDGUserCurrentUserIDDefaultsKey];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.email forKey:kDGUserCurrentUserEmail];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.username forKey:kDGUserCurrentUserUsername];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.phone forKey:kDGUserCurrentUserPhone];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.full_name forKey:kDGUserCurrentUserFullName];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.contactable forKey:kDGUserCurrentUserContactable];
    [RFKeychain setPassword:currentUser.password account:kDoGoodAccount service:kDoGoodService];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isSignedIn {
	return self.userID != nil;
}

+ (void)setNewPassword:(NSString *)password {
    [RFKeychain setPassword:password account:kDoGoodAccount service:kDoGoodService];
}

#pragma mark - Send Password
#pragma mark - Sign Out
- (void)signOutWithMessage:(BOOL)showMessage {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserIDDefaultsKey];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserFullName];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserUsername];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserPhone];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserEmail];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserContactable];
    [[NSUserDefaults standardUserDefaults] synchronize];
 
    self.userID = nil;
    self.email = nil;
    self.username = nil;
    self.password = nil;
    self.password_confirmation = nil;
    self.full_name = nil;
    self.phone = nil;
    self.contactable = nil;

    [RFKeychain deletePasswordForAccount:kDoGoodAccount service:kDoGoodService];
    [DGUser setAuthorizationHeader];

    if (showMessage) {
    }

    [[RKObjectManager sharedManager].HTTPClient deletePath:user_end_session_path parameters:nil success:nil failure:nil];
    DebugLog(@"why isn't notification posting, %@", DGUserDidSignOutNotification);

    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSignOutNotification object:self];
}

#pragma mark - Points
- (void)updatePoints {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/users/points" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        DGUser *user = mappingResult.array[0];
        self.points = user.points;
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdatePointsNotification object:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

@end
