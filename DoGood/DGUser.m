#import "DGUser.h"
#import "DGError.h"
#import "RFKeychain.h"
#import "DGUserProfileViewController.h"
#import "DGAuthenticateViewController.h"

static DGUser* currentUser = nil;

@implementation DGUser

#pragma mark - Class methods
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
            currentUser.avatar_url = [defaults objectForKey:kDGUserCurrentUserAvatar];
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

#pragma mark - Welcome screen
+ (BOOL)showWelcomeMessage {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"welcomeShown"]) {
        return NO;
    } else {
        return YES;
    }
}

+ (void)welcomeMessageShown {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"welcomeShown"];
}

#pragma mark - HTTP Headers
+ (void)setAuthorizationHeader {
    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:currentUser.email password:currentUser.password];
}

+ (void)setUpUserAuthentication {
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBasicHTTPAccessFromAuthenticationNotification:)
                                                 name:DGUserDidSignInNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBasicHTTPAccessFromAuthenticationNotification:)
                                                 name:DGUserDidSignOutNotification
                                               object:nil];

    [DGUser currentUser];
    [DGUser verifySavedUser];
}

+ (void)setBasicHTTPAccessFromAuthenticationNotification:(NSNotification*)notification {
    [DGUser setAuthorizationHeader];
}

#pragma mark - Sign In
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
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.email forKey:kDGUserCurrentUserEmail];
   	[[NSUserDefaults standardUserDefaults] setObject:currentUser.points forKey:kDGUserCurrentUserPoints];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.phone forKey:kDGUserCurrentUserPhone];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.full_name forKey:kDGUserCurrentUserFullName];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.biography forKey:kDGUserCurrentUserBiography];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.location forKey:kDGUserCurrentUserLocation];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.contactable forKey:kDGUserCurrentUserContactable];
	[[NSUserDefaults standardUserDefaults] setObject:currentUser.avatar_url forKey:kDGUserCurrentUserAvatar];
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
    self.avatar_url = nil;
    self.twitter_id = nil;
    self.facebook_id = nil;
    self.points = nil;

    [RFKeychain deletePasswordForAccount:kDoGoodAccount service:kDoGoodService];
    [DGUser setAuthorizationHeader];

    if (showMessage) {
    }

    [[RKObjectManager sharedManager].HTTPClient deletePath:user_end_session_path parameters:nil success:nil failure:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSignOutNotification object:self];
}

#pragma mark - Points
- (void)updatePoints {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/users/points" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        DGUser *user = mappingResult.array[0];
        self.points = user.points;
        [DGUser assignDefaults];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdatePointsNotification object:self];
        });
    } failure:nil
    ];
}

#pragma mark - Social
- (void)saveSocialID:(NSString *)socialID withType:(NSString *)socialType success:(SocialSuccessBlock)completion failure:(ErrorBlock)failure {
    if (socialType == nil) {
        return;
    }

    DGUser *user = [DGUser new];

    if ([socialType isEqualToString:@"twitter"]) {
        if (![self.twitter_id  isEqualToString:socialID]) {
            user.twitter_id = socialID;
        } else {
            completion(YES);
            return;
        }
    } else if ([socialType isEqualToString:@"facebook"]) {
        if (![self.facebook_id isEqualToString:socialID]) {
            user.facebook_id = socialID;
        } else {
            completion(YES);
            return;
        }
    }

    [[RKObjectManager sharedManager] postObject:user path:@"/users/social" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (user.twitter_id) {
            self.twitter_id = user.twitter_id;
        } else if (user.facebook_id) {
            self.facebook_id = user.facebook_id;
        }
        [DGUser assignDefaults];
        completion(YES);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)saveSocialID:(NSString *)socialID withType:(NSString *)socialType {
    [self saveSocialID:socialID withType:socialType success:^(BOOL success) {
    } failure:^(NSError *error) {
    }];
}

#pragma mark - Decoration
- (NSURL *)avatarURL {
    if ([self.avatar_url isEqualToString:@""]) {
        return nil;
    } else {
        return [NSURL URLWithString:self.avatar_url];
    }
}

#pragma mark - Profile helper
+ (void)openProfilePage:(NSNumber *)userID inController:(UINavigationController *)nav  {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserProfileViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    controller.userID = userID;
    [nav pushViewController:controller animated:YES];
}

- (BOOL)authorizeAccess:(UIViewController *)controller {
    if ([self isSignedIn]) {
        return YES;
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
        DGAuthenticateViewController *authenticate = [storyboard instantiateViewControllerWithIdentifier:@"Authenticate"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:authenticate];
        [controller presentViewController:nav animated:YES completion:nil];
        return NO;
    }
}

#pragma mark - Formatters
- (NSString *)pointsText {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    return [formatter stringFromNumber:self.points];
}

#pragma mark - Clean up
- (void)dealloc {
   	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:DGUserDidSignInNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:DGUserDidSignOutNotification
                                               object:nil];
}

- (BOOL)hasBeenNominated {
	return [self.nominations_by_user_goods_count intValue] > 0;
}

- (BOOL)hasFollowedGoods {
    return [self.followed_goods_count intValue] > 0;
}

- (BOOL)hasVotes {
    return [self.liked_goods_count intValue] > 0;
}

- (BOOL)hasPostedNominations {
    return [self.nominations_for_user_goods_count intValue] > 0;
}

- (BOOL)hasPostedHelpWantedGoods {
    return [self.help_wanted_by_user_goods_count intValue] > 0;
}

@end
