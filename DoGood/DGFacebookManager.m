#import "DGFacebookManager.h"
#import <SocialAuth/SocialAuth.h>
#import <Social/Social.h>

@interface DGFacebookManager () <UIActionSheetDelegate>
@property (nonatomic, readonly, strong) SAAccountStore *accountStore;
@end

@implementation DGFacebookManager

@synthesize accountStore = _accountStore;

#pragma mark - Initialization
- (SAAccountStore *) accountStore {
	if (!_accountStore) {
        postOptions = @{
            ACFacebookAppIdKey : FACEBOOK_APP_ID,
            ACFacebookPermissionsKey : @[ @"publish_actions", @"publish_stream" ],
            ACFacebookAudienceKey: ACFacebookAudienceFriends
        };
		_accountStore = [SAAccountStore new];
	}
	return _accountStore;
}

#pragma mark - Posting
- (void)checkFacebookPostAccessWithSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSString *error))failure {
   	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    DebugLog(@"post options %@", postOptions);
   	[self.accountStore requestAccountTyped:accountType withOptions:postOptions  completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            success(@"Woot");
        } else {
            failure(@"Fail");
        }
    }];
}

- (void)promptForPostAccess {
    UIAlertView *alertViewTwitter = [[UIAlertView alloc] initWithTitle:@"No Access" message:@"There are no Facebook accounts configured or Do Good access is disabled. Check Settings > Facebook and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertViewTwitter show];
}

- (void)postToFacebook:(NSString *)status andImage:(UIImage *)image withSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSString *error))failure {
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
                } else {
                    failure(@"failed to post good");
                }
            }];
        } else {
            failure(@"Fail");
        }
    }];
}

- (NSString *)accessTokenFromAccount:(ACAccount *)account {
   return [NSString stringWithFormat:@"%@", account.credential.oauthToken];
}

#pragma mark - Friends
- (void)findFacebookFriendsWithSuccess:(void (^)(NSArray *msg))success failure:(void (^)(NSString *error))failure {
   	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{
        ACFacebookAppIdKey : FACEBOOK_APP_ID,
        ACFacebookPermissionsKey : @[@"email"],
        ACFacebookAudienceKey: ACFacebookAudienceEveryone
    };
   	[self.accountStore requestAccountTyped:accountType withOptions:options  completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            [self findFacebookIDForAccount:account];
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
                             failure([NSString stringWithFormat:@"JSON Error: %@", [jsonError localizedDescription]]);
                         }
                     } else {
                         failure([NSString stringWithFormat:@"The response status code is %d", urlResponse.statusCode]);
                     }
                 } else {
                     failure(@"no response data");
                 }
             }];
        } else {
            failure(@"No account set up");
        }
    }];
}

// make this a call block structure too and call it from third parties - if we
// don't have a facebook user for this account then get one
- (void)findFacebookIDForAccount:(ACAccount *)account {
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];

    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                              requestMethod:SLRequestMethodGET
                                                        URL:url
                                                 parameters:nil];
    request.account = account;

    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", meDataString);
        if (responseData) {
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError;
                NSDictionary *statusData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                NSString *facebookID = statusData[@"id"];
                DebugLog(@"fb id %@", facebookID);
                [[DGUser currentUser] saveSocialID:facebookID withType:@"facebook"];
            } else {
                DebugLog(@"failed to look up me");
            }
        } else {
            DebugLog(@"failed to look up me");
        }
    }];
}

@end
