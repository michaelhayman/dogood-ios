#import "DGUser.h"
#import "DGError.h"
#import "NSData+Base64.h"
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
            currentUser.first_name = [defaults objectForKey:kDGUserCurrentUserFirstName];
            currentUser.last_name = [defaults objectForKey:kDGUserCurrentUserLastName];
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
+ (NSString *)basicAuthorizationHeader {
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", currentUser.email, currentUser.password];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithSeparateLines:YES]];
}

+ (void)setAuthorizationHeader {
    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:currentUser.email password:currentUser.password];
}

+ (void)verifySavedUser {
    if ([currentUser isSignedIn]) {
        [[RKObjectManager sharedManager] postObject:self path:user_session_path parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if ([currentUser isSignedIn]) {
                [[DGUser currentUser] signOutWithMessage:NO];
            }
        }];
    }
}

+ (void)signInWasSuccessful {
    [self assignDefaults];

    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:currentUser.email password:currentUser.password];

	[[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSignInNotification object:self];
}

+ (void) assignDefaults {
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.userID forKey:kDGUserCurrentUserIDDefaultsKey];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.first_name forKey:kDGUserCurrentUserFirstName];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.last_name forKey:kDGUserCurrentUserLastName];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.email forKey:kDGUserCurrentUserEmail];
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
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserFirstName];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserLastName];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserEmail];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserContactable];
    [[NSUserDefaults standardUserDefaults] synchronize];
 
    self.userID = nil;
    self.email = nil;
    self.password = nil;
    self.password_confirmation = nil;
    self.first_name = nil;
    self.last_name = nil;
    self.contactable = nil;
    self.terms_accepted = nil;

    [RFKeychain deletePasswordForAccount:kDoGoodAccount service:kDoGoodService];
    [DGUser setAuthorizationHeader];

    if (showMessage) {
    }

    [[RKObjectManager sharedManager].HTTPClient deletePath:user_end_session_path parameters:nil success:nil failure:nil];
    DebugLog(@"why isn't notification posting, %@", DGUserDidSignOutNotification);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"SignOut" object:self];
}

@end
