#import "DGFacebookManager.h"
#import <SocialAuth/SocialAuth.h>
#import <Social/Social.h>

@interface DGFacebookManager () <UIActionSheetDelegate>
@property (nonatomic, readonly, strong) SAAccountStore *accountStore;
@end

@implementation DGFacebookManager

@synthesize accountStore = _accountStore;

#pragma mark - Initialization
- (id)init {
    self = [super init];
    if (self) {
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
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"There are no Facebook accounts configured or Do Good access is disabled on this device. Check Settings > Facebook and try again.", nil)
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
- (void)checkFacebookPostAccessWithSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *error))failure {
   	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    DebugLog(@"post options %@", postOptions);
   	[self.accountStore requestAccountTyped:accountType withOptions:postOptions  completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            success(@"Woot");
        } else {
            failure(unableToPostError);
        }
    }];
}

- (void)promptForPostAccess {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access" message:@"There are no Facebook accounts configured or Do Good access is disabled. Check Settings > Facebook and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)postToFacebook:(NSString *)status andImage:(UIImage *)image withSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *postError))failure {
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    DebugLog(@"post options %@", postOptions);

   	[self.accountStore requestAccountTyped:accountType withOptions:postOptions  completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];

            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"message"] = @"I did some good!";
            params[@"link"] = @"http://www.dogoodapp.com/";
            params[@"name"] = @"Do Good, get a high score and earn rewards.";
            params[@"caption"] = status;
            params[@"access_token"] = [self accessTokenFromAccount:account];

            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:url parameters:params];

            [request setAccount:account];

            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                DebugLog(@"error %@\n url %@", error, urlResponse);
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                DebugLog(@"Facebook Response : %@",response);

                if (!error) {
                    success(@"posted good!");
                    [self findFacebookIDForAccount:account withSuccess:^(NSString *msg) {
                        DebugLog(@"found id");
                    } failure:^(NSError *findError) {
                        DebugLog(@"didn't find id");
                    }];
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
- (void)findFacebookFriendsWithSuccess:(void (^)(NSArray *msg))success failure:(void (^)(NSError *findError))failure {
   	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{
        ACFacebookAppIdKey : FACEBOOK_APP_ID,
        ACFacebookPermissionsKey : @[@"email"],
        ACFacebookAudienceKey: ACFacebookAudienceEveryone
    };
   	[self.accountStore requestAccountTyped:accountType withOptions:options completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            [self findFacebookIDForAccount:account withSuccess:^(NSString *msg) {
                 DebugLog(@"found id");
            } failure:^(NSError *findError) {
                 DebugLog(@"didn't find id");
            }];
            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];

            NSDictionary *params = @{ @"access_token": [self accessTokenFromAccount:account] };

            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
            [request setAccount:account];
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 // DebugLog(@"%@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                 if (responseData) {
                     if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                         NSError *jsonError;
                         NSDictionary *statusData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];

                         if (statusData) {
                             // DebugLog(@"Status Response: %@\n", statusData);
                             NSArray *facebookUserIDs= [statusData valueForKey:@"data"];
                             NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:[facebookUserIDs count]];
                             for (NSDictionary *dict in facebookUserIDs) {
                                 [ids addObject:dict[@"id"]];
                             }
                             success(ids);
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

- (void)findFacebookIDForAccount:(ACAccount *)account withSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *findError))failure {
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
                    DebugLog(@"Facebook id: %@", facebookID);
                    [[DGUser currentUser] saveSocialID:facebookID withType:@"facebook"];
                    success(@"Saved the ID!");
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
