#import "DGFacebookManager.h"
#import <SocialAuth/SocialAuth.h>
#import <Social/Social.h>

@interface DGFacebookManager () <UIActionSheetDelegate>
@property (nonatomic, readonly, strong) SAAccountStore *accountStore;
@end

@implementation DGFacebookManager

@synthesize accountStore = _accountStore;

#pragma mark - Initialization
- (id)initWithAppName:(NSString *)name {
    self = [super init];
    if (self) {
        appName = name;
        postOptions = @{
            ACFacebookAppIdKey : FACEBOOK_APP_ID,
            ACFacebookPermissionsKey : @[ @"publish_actions", @"publish_stream" ],
            ACFacebookAudienceKey: ACFacebookAudienceFriends
        };
        [self setupErrors];
    }
    return self;
}

- (SAAccountStore *) accountStore {
	if (!_accountStore) {
        _accountStore = [SAAccountStore new];
	}
	return _accountStore;
}

- (void)setupErrors {
   NSDictionary *unableToPostErrorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to post", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Facebook may be down or insufficient permissions?", nil)
    };
    unableToPostError = [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:unableToPostErrorInfo];

    NSDictionary *noAccountErrorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"No Account", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try checking Settings > Facebook.", nil)
    };
    noAccountError = [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:noAccountErrorInfo];

    NSDictionary *checkSettingsErrorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to Access Facebook", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Access denied.", nil),
        NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat:@"There are no Facebook accounts configured or %@ access is disabled on this device. Check Settings > Facebook and try again.", appName]
    };
    checkSettingsError = [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:checkSettingsErrorInfo];
}

- (NSError *)responseErrorWithResponseCode:(NSInteger)code {
    NSString *statusCodeMsg = [NSString stringWithFormat:@"The response status code is %d", code];
    NSDictionary *errorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"Response error", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Access denied.", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(statusCodeMsg, nil)
    };
    return [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:errorInfo];
}

#pragma mark - Posting
- (void)checkFacebookPostAccessWithSuccess:(PostAccessBlock)success failure:(ErrorBlock)failure {
   	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
   	[self.accountStore requestAccountTyped:accountType withOptions:postOptions  completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            success(YES, @"Permission granted to post.");
        } else {
            failure(unableToPostError);
        }
    }];
}

- (void)promptForPostAccess {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access" message:[NSString stringWithFormat:@"There are no Facebook accounts configured or %@ access is disabled. Check Settings > Facebook and try again.", appName ] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)postToFacebook:(NSMutableDictionary *)params andImage:(UIImage *)image withSuccess:(PostCompletionBlock)success failure:(ErrorBlock)failure {
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

   	[self.accountStore requestAccountTyped:accountType withOptions:postOptions  completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];

            params[@"access_token"] = [self accessTokenFromAccount:account];

            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:url parameters:params];
            [request setAccount:account];

            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (!error) {
                    success(YES, @"Post successful!", account);
                } else {
                    failure(unableToPostError);
                }
            }];
        } else {
            failure(noAccountError);
        }
    }];
}

- (NSString *)accessTokenFromAccount:(ACAccount *)account {
   return [NSString stringWithFormat:@"%@", account.credential.oauthToken];
}

#pragma mark - Friends
- (void)findFacebookFriendsWithSuccess:(FindFriendsBlock)success failure:(ErrorBlock)failure {
   	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{
        ACFacebookAppIdKey : FACEBOOK_APP_ID,
        ACFacebookPermissionsKey : @[@"email"],
        ACFacebookAudienceKey: ACFacebookAudienceEveryone
    };
   	[self.accountStore requestAccountTyped:accountType withOptions:options completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];

            NSDictionary *params = @{ @"access_token": [self accessTokenFromAccount:account] };

            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
            [request setAccount:account];
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 if (responseData) {
                     if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                         NSError *jsonError;
                         NSDictionary *statusData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];

                         if (statusData) {
                             NSArray *facebookUserIDs= [statusData valueForKey:@"data"];
                             NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:[facebookUserIDs count]];
                             for (NSDictionary *dict in facebookUserIDs) {
                                 [ids addObject:dict[@"id"]];
                             }
                             success(YES, ids, account);
                         } else {
                             failure(jsonError);
                         }
                     } else {
                         failure([self responseErrorWithResponseCode:urlResponse.statusCode]);
                     }
                 } else {
                     failure(error);
                 }
             }];
        } else {
            failure(noAccountError);
        }
    }];
}

- (void)findFacebookIDForAccount:(ACAccount *)account withSuccess:(FindIDBlock)success failure:(ErrorBlock)failure {
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];

    NSDictionary *params = @{ @"access_token": [self accessTokenFromAccount:account] };
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
    request.account = account;

    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", meDataString);
        if (responseData) {
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError;
                NSDictionary *statusData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                if (statusData) {
                    NSString *facebookID = statusData[@"id"];
                    success(YES, facebookID);
                } else {
                    failure(error);
                }
            } else {
                failure([self responseErrorWithResponseCode:urlResponse.statusCode]);
            }
        } else {
            failure(error);
        }
    }];
}

@end
