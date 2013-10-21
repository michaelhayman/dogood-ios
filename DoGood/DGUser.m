#import "DGUser.h"
#import "DGError.h"
#import "RFKeychain.h"
#import "DGUserProfileViewController.h"

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
            currentUser.points = [defaults objectForKey:kDGUserCurrentUserPoints];
            currentUser.full_name = [defaults objectForKey:kDGUserCurrentUserFullName];
            currentUser.location = [defaults objectForKey:kDGUserCurrentUserLocation];
            currentUser.biography = [defaults objectForKey:kDGUserCurrentUserBiography];
            currentUser.phone = [defaults objectForKey:kDGUserCurrentUserPhone];
            currentUser.email = [defaults objectForKey:kDGUserCurrentUserEmail];
            currentUser.contactable = [defaults objectForKey:kDGUserCurrentUserContactable];
            currentUser.avatar = [defaults objectForKey:kDGUserCurrentUserAvatar];
            currentUser.password = [RFKeychain passwordForAccount:kDoGoodAccount service:kDoGoodService];
            currentUser.facebook_id = [defaults objectForKey:kDGUserCurrentUserTwitterID];
            currentUser.twitter_id = [defaults objectForKey:kDGUserCurrentUserFacebookID];
		} else {
            currentUser = [[self alloc] init];
		}
	}
	return currentUser;
}

+ (void)setCurrentUser:(DGUser*)user {
	currentUser = user;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HTTP Headers
+ (void)setAuthorizationHeader {
    DebugLog(@"setting authorization header for %@ and %@", currentUser.email, currentUser.password);
    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:currentUser.email password:currentUser.password];
}

+ (void)setUpUserAuthentication {
    DebugLog(@"set up user auth");
    // Register for authentication notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBasicHTTPAccessFromAuthenticationNotification:)
                                                 name:DGUserDidSignInNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBasicHTTPAccessFromAuthenticationNotification:)
                                                 name:DGUserDidSignOutNotification
                                               object:nil];

    // [[DGUser currentUser] verifySavedUser];
    [DGUser currentUser];
    [DGUser verifySavedUser];
}

+ (void)setBasicHTTPAccessFromAuthenticationNotification:(NSNotification*)notification {
    DebugLog(@"set basic access");
    // [self setAuthorizationHeader];
    [DGUser setAuthorizationHeader];
}

#pragma mark - Sign In
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

    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:currentUser.email password:currentUser.password];

	[[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSignInNotification object:self];
}

+ (void) assignDefaults {
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.userID forKey:kDGUserCurrentUserIDDefaultsKey];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.email forKey:kDGUserCurrentUserEmail];
   	[[NSUserDefaults standardUserDefaults] setObject:currentUser.points forKey:kDGUserCurrentUserPoints];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.phone forKey:kDGUserCurrentUserPhone];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.full_name forKey:kDGUserCurrentUserFullName];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.biography forKey:kDGUserCurrentUserBiography];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.location forKey:kDGUserCurrentUserLocation];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.contactable forKey:kDGUserCurrentUserContactable];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.avatar forKey:kDGUserCurrentUserAvatar];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.twitter_id forKey:kDGUserCurrentUserTwitterID];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.facebook_id forKey:kDGUserCurrentUserFacebookID];
    [RFKeychain setPassword:currentUser.password account:kDoGoodAccount service:kDoGoodService];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isSignedIn {
	return self.userID != nil;
}

#pragma mark - Set Password
+ (void)setNewPassword:(NSString *)password {
    [DGUser currentUser].password = password;
    [RFKeychain setPassword:password account:kDoGoodAccount service:kDoGoodService];
    [self setAuthorizationHeader];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Sign Out
- (void)signOutWithMessage:(BOOL)showMessage {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserIDDefaultsKey];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserFullName];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserBiography];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserLocation];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserPoints];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserPhone];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserEmail];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserContactable];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserAvatar];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserTwitterID];
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kDGUserCurrentUserFacebookID];
    [[NSUserDefaults standardUserDefaults] synchronize];
 
    self.userID = nil;
    self.email = nil;
    self.password = nil;
    self.password_confirmation = nil;
    self.full_name = nil;
    self.biography = nil;
    self.location = nil;
    self.phone = nil;
    self.contactable = nil;
    self.avatar = nil;
    self.twitter_id = nil;
    self.facebook_id = nil;
    self.points = nil;

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
        [DGUser assignDefaults];
        // should probably synchronize here..
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdatePointsNotification object:self];
        });
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

#pragma mark - Social
- (void)saveSocialID:(NSString *)socialID withType:(NSString *)socialType {

    if (socialID == nil || socialType == nil) {
        return;
    }

    DGUser *user = [DGUser new];

    if ([socialType isEqualToString:@"twitter"]) {
        if (![self.twitter_id  isEqualToString:socialID]) {
            user.twitter_id = socialID;
        } else {
            return;
        }
    } else if ([socialType isEqualToString:@"facebook"]) {
        if (![self.facebook_id isEqualToString:socialID]) {
            user.facebook_id = socialID;
        } else {
            return;
        }
    }

    [[RKObjectManager sharedManager] postObject:user path:@"/users/social" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        DebugLog(@"successfully saved.");
        if (user.twitter_id) {
            self.twitter_id = user.twitter_id;
        } else if (user.facebook_id) {
            self.facebook_id = user.facebook_id;
        }
        [DGUser assignDefaults];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

// - (void)saveFacebookID:(NSString *)facebookID

#pragma mark - Profile helper
+ (void)openProfilePage:(NSNumber *)userID inController:(UINavigationController *)nav  {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserProfileViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    controller.userID = userID;
    [nav pushViewController:controller animated:YES];
}

#pragma mark - Formatters
- (NSString *)pointsText {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    return [formatter stringFromNumber:self.points];
}

@end
